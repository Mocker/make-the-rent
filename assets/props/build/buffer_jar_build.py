import bpy, math
from mathutils import Vector

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
    if alpha < 1.0:
        if hasattr(m, 'surface_render_method'):
            m.surface_render_method = 'DITHERED'
        else:
            m.blend_method = 'BLEND'
    return m

GLASS = mat('JarGlass', (0.62, 0.82, 0.88), 0.05, 0.18, 0.42)
GLASS_RIM = mat('JarRim', (0.45, 0.68, 0.78), 0.25, 0.3, 0.75)
GOLD = mat('CoinGold', (0.98, 0.72, 0.16), 0.55, 0.32)
GOLD_D = mat('CoinGoldDark', (0.85, 0.55, 0.08), 0.55, 0.38)
COPPER = mat('LidCopper', (0.62, 0.32, 0.18), 0.65, 0.35)
WHITE = mat('Shine', (0.95, 0.99, 1.0), 0.0, 0.25)

def finish(o, material):
    if material:
        o.data.materials.append(material)
    PARTS.append(o)
    return o

def cyl(name, loc, radius, depth, material, verts=40, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=rot)
    return finish(bpy.context.active_object, material)

def torus(name, loc, major, minor, material, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=40, minor_segments=12, location=loc, rotation=rot)
    return finish(bpy.context.active_object, material)

def box(name, loc, dims, material, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    o = bpy.context.active_object
    o.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(o, material)

# Coin fill inside (visible through the pale glass): solid gold mass + coin discs on top
cyl('CoinMass', (0, 0, 0.52), 0.66, 1.04, GOLD_D)
for i, (x, y, z, r) in enumerate([
        (-0.28, 0.10, 1.10, 0.30), (0.25, -0.12, 1.13, 0.32), (0.02, 0.22, 1.22, 0.28),
        (-0.15, -0.25, 1.20, 0.26), (0.30, 0.25, 1.06, 0.24)]):
    cyl(f'CoinTop{i}', (x, y, z), r, 0.13, GOLD)
# a few coin edges poking at the front glass line
for i, (x, z) in enumerate([(-0.30, 0.72), (0.28, 0.60), (0.0, 0.82)]):
    cyl(f'CoinEdge{i}', (x, 0.45, z), 0.20, 0.10, GOLD, rot=(math.radians(90), 0, 0))

# Glass body, neck and base ring
cyl('JarBody', (0, 0, 1.22), 0.80, 2.28, GLASS)
cyl('JarNeck', (0, 0, 2.42), 0.68, 0.22, GLASS)
torus('JarBaseRing', (0, 0, 0.10), 0.74, 0.09, GLASS_RIM, rot=(0, 0, 0))
torus('JarLipRing', (0, 0, 2.52), 0.66, 0.07, GLASS_RIM)

# Shine strip down the front (+Y face)
box('ShineStrip', (-0.38, 0.74, 1.35), (0.16, 0.05, 1.55), WHITE)

# Copper screw lid
cyl('Lid', (0, 0, 2.68), 0.74, 0.30, COPPER)
cyl('LidTop', (0, 0, 2.86), 0.60, 0.08, COPPER)

bpy.ops.object.select_all(action='DESELECT')
for o in PARTS:
    o.select_set(True)
bpy.context.view_layer.objects.active = PARTS[0]
bpy.ops.object.join()
obj = bpy.context.active_object
obj.name = 'BufferJar'
result = {'object': obj.name, 'prop': 'buffer_jar'}
