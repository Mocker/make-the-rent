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

GREEN = mat('TinGreen', (0.07, 0.38, 0.28), 0.45, 0.38)
GREEN_L = mat('TinGreenLight', (0.12, 0.50, 0.37), 0.45, 0.35)
BRASS = mat('Brass', (0.85, 0.62, 0.20), 0.7, 0.3)
DARK = mat('SlotDark', (0.05, 0.06, 0.06), 0.2, 0.6)
PLATE = mat('LabelPlate', (0.92, 0.88, 0.74), 0.1, 0.5)

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

def torus(name, loc, major, minor, material, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=32, minor_segments=10, location=loc, rotation=rot)
    return finish(bpy.context.active_object, material)

# Body and slightly oversized lid
box('TinBody', (0, 0, 0.72), (2.05, 1.30, 1.44), GREEN, bevel=0.07)
box('TinLid', (0, 0, 1.52), (2.18, 1.42, 0.30), GREEN_L, bevel=0.06)
# Coin slot on the lid
box('CoinSlot', (0.35, 0, 1.69), (0.72, 0.14, 0.05), DARK)
# Handle: half torus arching over the lid (lower half sunk into the lid)
torus('Handle', ( -0.45, 0, 1.62), 0.42, 0.075, BRASS, rot=(0, math.radians(90), 0))
# Brass latch on the front (+Y) face
box('LatchBase', (0, 0.68, 1.28), (0.34, 0.08, 0.42), BRASS)
box('LatchLoop', (0, 0.72, 1.05), (0.22, 0.08, 0.30), BRASS)
# Pale label plate on the front
box('LabelPlate', (0, 0.67, 0.68), (1.30, 0.05, 0.62), PLATE)
# Feet
for x in (-0.85, 0.85):
    box(f'Foot{x}', (x, 0, 0.04), (0.28, 1.05, 0.09), DARK)

bpy.ops.object.select_all(action='DESELECT')
for o in PARTS:
    o.select_set(True)
bpy.context.view_layer.objects.active = PARTS[0]
bpy.ops.object.join()
obj = bpy.context.active_object
obj.name = 'RentTin'
result = {'object': obj.name, 'prop': 'rent_tin'}
