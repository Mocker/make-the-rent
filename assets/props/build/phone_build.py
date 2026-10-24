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

BODY = mat('PhoneBody', (0.13, 0.14, 0.17), 0.5, 0.35)
SCREEN = mat('ScreenTeal', (0.10, 0.42, 0.48), 0.2, 0.18)
GLARE = mat('Glare', (0.75, 0.92, 0.95), 0.0, 0.2)
DARK = mat('LensDark', (0.03, 0.03, 0.05), 0.4, 0.3)
ACCENT = mat('CaseAccent', (0.90, 0.40, 0.16), 0.0, 0.5)

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

# Main slab, upright, broad face toward +Y
box('PhoneSlab', (0, 0, 1.05), (1.05, 0.14, 2.10), BODY, bevel=0.09)
# Bright accent edge along the bottom (case lip) so the slab reads at small size
box('CaseLip', (0, -0.01, 0.10), (1.07, 0.16, 0.14), ACCENT, bevel=0.04)
# Screen on the front face
box('Screen', (0, 0.085, 1.08), (0.88, 0.04, 1.82), SCREEN, bevel=0.03)
# Diagonal glare strip on the screen (rotated in the X-Z plane)
box('Glare', (-0.14, 0.11, 1.22), (0.15, 0.02, 0.95), GLARE, rot=(0, math.radians(28), 0))
# Speaker slot + camera lens at the top of the screen
box('Speaker', (0, 0.11, 1.93), (0.34, 0.02, 0.06), DARK)
cyl('Lens', (0.30, 0.11, 1.93), 0.05, 0.03, DARK, rot=(math.radians(90), 0, 0))
# Home indicator bar
box('HomeBar', (0, 0.11, 0.24), (0.36, 0.02, 0.05), GLARE)
# Side button on the right edge
box('SideButton', (0.56, 0, 1.45), (0.06, 0.10, 0.34), ACCENT)

bpy.ops.object.select_all(action='DESELECT')
for o in PARTS:
    o.select_set(True)
bpy.context.view_layer.objects.active = PARTS[0]
bpy.ops.object.join()
obj = bpy.context.active_object
obj.name = 'Phone'
result = {'object': obj.name, 'prop': 'phone'}
