import bpy, math

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
PARTS = []

def mat(name, color, metallic=0.0, rough=0.45, alpha=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes['Principled BSDF']
    bsdf.inputs['Base Color'].default_value = (*color, alpha)
    bsdf.inputs['Metallic'].default_value = metallic
    bsdf.inputs['Roughness'].default_value = rough
    bsdf.inputs['Alpha'].default_value = alpha
    return m

BODY = mat('FridgeBody', (0.78, 0.83, 0.86), 0.35, 0.35)
DOOR = mat('FridgeDoor', (0.86, 0.90, 0.93), 0.35, 0.3)
DARK = mat('GapDark', (0.10, 0.11, 0.12), 0.2, 0.6)
STEEL = mat('HandleSteel', (0.55, 0.58, 0.62), 0.8, 0.25)
ORANGE = mat('MagnetOrange', (0.95, 0.45, 0.15), 0.0, 0.4)
TEAL = mat('MagnetTeal', (0.10, 0.65, 0.62), 0.0, 0.4)
YELLOW = mat('MagnetYellow', (0.97, 0.78, 0.18), 0.0, 0.4)

def finish(o, material):
    if material:
        o.data.materials.append(material)
    PARTS.append(o)
    return o

def box(name, loc, dims, material, rot=(0,0,0), bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    o = bpy.context.active_object
    o.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0:
        mod = o.modifiers.new('bev', 'BEVEL')
        mod.width = bevel
        mod.segments = 2
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return finish(o, material)

def cyl(name, loc, radius, depth, material, rot=(0,0,0), verts=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=rot)
    return finish(bpy.context.active_object, material)

# Main body
box('FridgeBody', (0, 0, 1.72), (1.80, 1.30, 3.30), BODY, bevel=0.06)
# Door slabs on the front (+Y): freezer on top (z 2.28..3.32), fridge below
box('FreezerDoor', (0, 0.68, 2.80), (1.68, 0.10, 1.02), DOOR, bevel=0.04)
box('FridgeDoor', (0, 0.68, 1.12), (1.68, 0.10, 2.10), DOOR, bevel=0.04)
# Dark split line between the doors
box('SplitLine', (0, 0.72, 2.27), (1.70, 0.06, 0.09), DARK)
# Vertical bar handles on the right of each door front
cyl('FreezerHandle', (0.62, 0.78, 2.80), 0.045, 0.72, STEEL)
cyl('FridgeHandle', (0.62, 0.78, 1.45), 0.045, 1.05, STEEL)
# Cheerful magnets on the fridge door (identity cue at small size)
cyl('Magnet1', (-0.45, 0.75, 1.70), 0.10, 0.05, ORANGE, rot=(math.radians(90), 0, 0))
cyl('Magnet2', (-0.15, 0.75, 1.42), 0.08, 0.05, TEAL, rot=(math.radians(90), 0, 0))
box('MagnetNote', (-0.35, 0.74, 2.80), (0.42, 0.05, 0.52), mat('NotePaper', (0.96, 0.94, 0.85), 0.0, 0.6))
cyl('Magnet3', (-0.35, 0.78, 2.98), 0.07, 0.05, YELLOW, rot=(math.radians(90), 0, 0))
# Feet
for x in (-0.70, 0.70):
    box(f'Foot{x}', (x, 0, 0.05), (0.22, 1.05, 0.11), DARK)

bpy.ops.object.select_all(action='DESELECT')
for o in PARTS:
    o.select_set(True)
bpy.context.view_layer.objects.active = PARTS[0]
bpy.ops.object.join()
obj = bpy.context.active_object
obj.name = 'Fridge'
result = {'object': obj.name, 'prop': 'fridge'}
