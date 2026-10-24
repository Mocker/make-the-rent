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

CARD = mat('CardBlue', (0.16, 0.28, 0.78), 0.25, 0.32)
STRIPE = mat('StripeDark', (0.06, 0.06, 0.10), 0.3, 0.5)
GOLD = mat('ChipGold', (0.92, 0.70, 0.22), 0.7, 0.3)
PALE = mat('CardPale', (0.82, 0.87, 1.0), 0.1, 0.4)
STAND = mat('StandWood', (0.30, 0.20, 0.13), 0.0, 0.6)

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

# Stand: broad base + two angled back legs the card leans on
box('StandBase', (0, 0, 0.07), (2.30, 1.15, 0.14), STAND, bevel=0.04)
for x in (-0.80, 0.80):
    box(f'StandLeg{x}', (x, -0.38, 0.62), (0.16, 0.14, 1.15), STAND, rot=(math.radians(-18), 0, 0))
# Card slab, upright, broad face toward +Y (front), leaning slightly back
CARD_Z = 1.06
box('CardSlab', (0, 0, CARD_Z), (2.45, 0.13, 1.55), CARD, rot=(math.radians(-6), 0, 0), bevel=0.09)
# Magnetic stripe across the top of the front face
box('Stripe', (0, 0.085, CARD_Z + 0.60), (2.30, 0.04, 0.24), STRIPE, rot=(math.radians(-6), 0, 0))
# Chip on the front-left
box('Chip', (-0.72, 0.09, CARD_Z + 0.12), (0.46, 0.04, 0.36), GOLD, rot=(math.radians(-6), 0, 0), bevel=0.04)
box('ChipLine', (-0.72, 0.105, CARD_Z + 0.12), (0.46, 0.02, 0.07), STRIPE, rot=(math.radians(-6), 0, 0))
# Number blocks along the bottom front
for i, x in enumerate((-0.86, -0.29, 0.29, 0.86)):
    box(f'NumBlock{i}', (x, 0.09, CARD_Z - 0.48), (0.44, 0.04, 0.16), PALE, rot=(math.radians(-6), 0, 0))

bpy.ops.object.select_all(action='DESELECT')
for o in PARTS:
    o.select_set(True)
bpy.context.view_layer.objects.active = PARTS[0]
bpy.ops.object.join()
obj = bpy.context.active_object
obj.name = 'CreditCard'
result = {'object': obj.name, 'prop': 'credit_card'}
