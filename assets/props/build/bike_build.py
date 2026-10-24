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
    return m

FRAME = mat('FrameCoral', (0.88, 0.28, 0.20), 0.3, 0.35)
TIRE = mat('TireBlack', (0.07, 0.07, 0.08), 0.0, 0.7)
HUB = mat('HubSilver', (0.72, 0.74, 0.78), 0.8, 0.3)
SEAT = mat('SeatBrown', (0.32, 0.20, 0.12), 0.0, 0.55)

def finish(o, material):
    if material:
        o.data.materials.append(material)
    PARTS.append(o)
    return o

def box(name, loc, dims, material, rot=(0,0,0)):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    o = bpy.context.active_object
    o.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(o, material)

def cyl(name, loc, radius, depth, material, rot=(0,0,0), verts=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=rot)
    return finish(bpy.context.active_object, material)

def torus(name, loc, major, minor, material, rot=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=36, minor_segments=12, location=loc, rotation=rot)
    return finish(bpy.context.active_object, material)

def tube(name, p1, p2, radius, material):
    a, b = Vector(p1), Vector(p2)
    mid = (a + b) / 2
    d = b - a
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=radius, depth=d.length, location=mid)
    o = bpy.context.active_object
    o.rotation_mode = 'QUATERNION'
    o.rotation_quaternion = Vector((0, 0, 1)).to_track_quat('Z', 'Y') if False else (Vector((0,0,1))).rotation_difference(d.normalized())
    return finish(o, material)

# Bike profile lies in the X-Z plane (length along X, up = Z), thin in Y.
REAR = (-0.78, 0, 0.58)
FRONT = (0.78, 0, 0.58)
BB = (-0.05, 0, 0.48)      # bottom bracket
SEAT_TOP = (-0.38, 0, 1.32)
HEAD_TOP = (0.55, 0, 1.28)
HEAD_BOT = (0.68, 0, 1.04)

# Wheels: thick torus tyres in the X-Z plane + hub + a few fat spokes
for label, c in (('Rear', REAR), ('Front', FRONT)):
    torus(f'{label}Wheel', c, 0.50, 0.10, TIRE, rot=(math.radians(90), 0, 0))
    cyl(f'{label}Hub', c, 0.11, 0.20, HUB, rot=(math.radians(90), 0, 0))
    for ang in (0, 60, 120):
        r = math.radians(ang)
        d = Vector((math.cos(r), 0, math.sin(r)))
        tube(f'{label}Spoke{ang}', tuple(Vector(c) - d * 0.42), tuple(Vector(c) + d * 0.42), 0.028, HUB)

# Frame tubes (exaggerated radius so they survive sprite scale)
tube('Chainstay', REAR, BB, 0.075, FRAME)
tube('Seatstay', REAR, SEAT_TOP, 0.075, FRAME)
tube('SeatTube', BB, SEAT_TOP, 0.085, FRAME)
tube('DownTube', BB, HEAD_BOT, 0.095, FRAME)
tube('TopTube', SEAT_TOP, HEAD_TOP, 0.085, FRAME)
tube('HeadTube', HEAD_BOT, HEAD_TOP, 0.10, FRAME)
tube('Fork', HEAD_BOT, FRONT, 0.075, FRAME)
tube('SeatPost', SEAT_TOP, (-0.40, 0, 1.44), 0.06, HUB)
tube('Stem', HEAD_TOP, (0.50, 0, 1.46), 0.06, HUB)

# Saddle, handlebar (along Y so it reads from the front), crank
box('Saddle', (-0.42, 0, 1.50), (0.55, 0.26, 0.13), SEAT)
cyl('Handlebar', (0.50, 0, 1.48), 0.055, 0.62, SEAT, rot=(math.radians(90), 0, 0))
cyl('Crank', BB, 0.17, 0.16, HUB, rot=(math.radians(90), 0, 0))
box('PedalL', (-0.22, 0, 0.30), (0.30, 0.16, 0.07), SEAT)
box('PedalR', (0.12, 0, 0.66), (0.30, 0.16, 0.07), SEAT)

bpy.ops.object.select_all(action='DESELECT')
for o in PARTS:
    o.select_set(True)
bpy.context.view_layer.objects.active = PARTS[0]
bpy.ops.object.join()
obj = bpy.context.active_object
obj.name = 'Bike'
result = {'object': obj.name, 'prop': 'bike'}
