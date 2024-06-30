import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;
import flixel.addons.display.FlxBackdrop;

var gradient:FlxSprite;
var logo:FlxSprite;
var sans:FlxSprite;
var particles:FlxTypedGroup<FlxSprite>;
var buttons:FlxTypedGroup<FlxSprite>;

// Button list huhh
var list = ['start', 'options', 'credits'];

// Button width
var width = 245;
// Selection index
var curSelect = -1;
// Cool down for intro anim
var cooldown:Float = 0;
// Gradient intro scale lerp
var scaleLerp = 0;
// Particle pooling
var pools = [];

var words:Array<String> = [
    'last night of funkin',
    'hola 2 am',
    'im sans believe me look eeeeeeeeeeeeeeeeee',
    'wow a last breath fnf mod',
    'rebreath assss',
    'dumbass abner',
    'vuela pega y esquiva',
    'y el dinero theo',
    'nenenenene',
    'codename is soo god',
    'null object referece'
];
var me:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
var camThing:FlxCamera = new FlxCamera();

function create()
{
    trace('[LNOF] Main Menu');

    gradient = new FlxSprite();
    gradient.loadGraphic(Paths.image('ut/menu/gradient'));
    gradient.scrollFactor.set(0.3, 0.3);
    gradient.color = FlxColor.fromString('#520D22');
    gradient.width = FlxG.width * 5;
    add(gradient);

    FlxG.cameras.add(camThing);
    FlxCamera.defaultCameras = [camThing];

    camThing.bgColor = 0x00FFFFFF;

    for (i in 0...15)
    {
        var newText = words[FlxG.random.int(0, words.length - 1)];

        words.remove(newText);

        var text:FlxText = new FlxText();
        text.text = newText;
        text.setFormat(Paths.font("undertale-cool.ttf"), 32, 0xFFFFFF);
        text.regenGraphic();

        var sprite = new FlxBackdrop(text.graphic, FlxAxes.X, 10);
        sprite.y = 50 * i;
        sprite.velocity.set(100 * (i % 2 == 0 ? 1 : -1));
        sprite.alpha = 0.01;
        me.add(sprite);

        text.destroy();
    }

    me.cameras = [FlxG.camera];
    FlxG.camera.angle = 10;
    add(me);

    particles = new FlxTypedGroup(25);
    add(particles);

    buttons = new FlxTypedGroup();
    add(buttons);

    logo = new FlxSprite();
    logo.loadGraphic(Paths.image('ut/menu/logo'));
    logo.scale.set(0.5, 0.5);
    logo.updateHitbox();
    logo.x = FlxG.width * -0.008;
    logo.y = -logo.height;
    logo.scrollFactor.set(0.6, 0.6);
    add(logo);

    sans = new FlxSprite();
    sans.frames = Paths.getSparrowAtlas('ut/menu/sans');
    sans.animation.addByPrefix('idle', "sans", 24);
    sans.animation.play('idle');
    sans.scale.set(0.55, 0.55);
    sans.x = FlxG.width;
    sans.y = FlxG.height * 0.05;
    sans.updateHitbox();
    sans.scrollFactor.set(1, 1);
    add(sans);

    for (i in 0...list.length)
    {
        var button:FlxSprite = new FlxSprite();
        button.loadGraphic(Paths.image('ut/menu/buttons/' + list[i]));
        button.x = FlxG.width * 0.13 + (width - button.width) / 2;
        button.y = FlxG.height * 0.5 + (100 * i) + (i == 1 ? 12 : 0);
        button.ID = i;
        button.scrollFactor.set(0.4 + (0.065 * i), 0.4 + (0.065 * i));
        buttons.add(button);
    }

    var cne:FunkinText = new FunkinText(5);
    cne.text = 'FNF: Codename Engine v' + Application.current.meta.get('version') + ' [Commit ' + engine.commit + ' (' + engine.hash + ')]';
    cne.y = FlxG.height - cne.height - 8;
    cne.size = 15.5;
    cne.scrollFactor.set(gradient.scrollFactor.x, gradient.scrollFactor.y);
    add(cne);

    var lnof:FunkinText = new FunkinText(5);
    lnof.text = 'Last Night Of Funkin v1.0 [PROTOTYPE]';
    lnof.y = cne.y - cne.height * 1.2;
    lnof.size = 15.5;
    lnof.scrollFactor.set(gradient.scrollFactor.x, gradient.scrollFactor.y);
    add(lnof);
}

function update(elapsed)
{
    FlxG.mouse.visible = usingMouse;

    if (FlxG.keys.justPressed.SEVEN)
    {
        openSubState(new EditorPicker());
    }
    if (controls.SWITCHMOD) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }

    updateSelection();

    // keeping this while i figure out error when using `usingMouse`
    // if (1 == 0)
    // was easy to fix (2 weeks later lol)
    if (!usingMouse)
    {
        // Infinite path cuz is good
        // https://gamedev.stackexchange.com/questions/43691/how-can-i-move-an-object-in-an-infinity-or-figure-8-trajectory
        final scale = 2 / (3 - FlxMath.fastCos(2*curMeasureFloat));
        camera.scroll.x = scale * (FlxMath.fastCos(curMeasureFloat * Math.PI) * 12);
        camera.scroll.y = scale * ((FlxMath.fastSin(curMeasureFloat * 2 * Math.PI) * 0.5) * 12);
    } else {
        camera.scroll.x = FlxG.mouse.x * -0.0325;
        camera.scroll.y = FlxG.mouse.y * -0.0325;
    }

    cooldown += elapsed;

    if (cooldown < Conductor.crochet / 1000) {
        gradient.scale.y = 0;
        return;
    }

    sans.x = FlxMath.lerp(sans.x, FlxG.width * 0.42, .05);
    logo.y = FlxMath.lerp(logo.y, FlxG.height * 0.06, .05);
    scaleLerp = FlxMath.lerp(scaleLerp, 1, .05);

    gradient.scale.y = scaleLerp + (Math.abs(FlxMath.fastSin(Conductor.curBeatFloat * Math.PI) * 0.5)) * scaleLerp;
    gradient.updateHitbox();
    gradient.y = FlxG.height - gradient.height;
    gradient.screenCenter(FlxAxes.X);

    updateParticles(elapsed);
}
function select()
{
    CoolUtil.playMenuSFX(1, 0.7);
    new FlxTimer().start(Conductor.crochet / 800, (t) -> {
        FlxG.switchState(new StoryMenuState());
    });
    FlxTween.tween(camera, { zoom: 2, angle: 10 }, Conductor.crochet / 600, { ease: FlxEase.backInOut });
}
var usingMouse = false;
function updateSelection()
{
    if (FlxG.mouse.justMoved && !usingMouse)
        usingMouse = true;

    if (controls.UP_P || controls.DOWN_P)
    {
        CoolUtil.playMenuSFX(0, 2);
        usingMouse = false;
    }
    if (controls.UP_P) curSelect -= 1;
    if (controls.DOWN_P) curSelect += 1;
    
    // Bound selection
    curSelect = (curSelect < 0 ? curSelect + buttons.members.length : curSelect) % buttons.members.length;

    buttons.forEach(item -> {
        final selected:Bool = FlxG.mouse.overlaps(item) || (!usingMouse && curSelect == item.ID);
        
        if (selected && (controls.ACCEPT || FlxG.mouse.justPressed))
            select();
        item.loadGraphic(Paths.image('ut/menu/buttons/' + list[item.ID] + (selected ? '_selected' : '')));

        if (selected && curSelect != item.ID) {
            curSelect = item.ID;
            CoolUtil.playMenuSFX(0, 0.7);
        }
    });
}
// FlxTypedGroup is dumb in hscript so i had to do pooling system for myself -theo
function addParticlePool(particle)
{
    particle.kill();
    pools.push(particle);
}
function getParticle()
{
    if (pools.length == 0) return new FlxSprite();
    pools[0].revive();
    return pools.shift();
}
function updateParticles(elapsed)
{
    if (FlxG.random.bool(5)) {
        var particle = getParticle();
        particle.loadGraphic(Paths.image('ut/menu/particle'));
        particle.scale.set(0.1, 0.1);
        particle.x = FlxG.width * 0.05 + FlxG.width * 0.85 * Math.random();
        particle.y = FlxG.height;
        particle.velocity.y = -450;
        particle.alpha = 0.8;
        particle.ID = 0;

        particle.color = FlxColor.BLACK;

        particle.scrollFactor.set(0.4, 0.4);
        particles.add(particle);

        for (i in 0...3)
        {
            new FlxTimer().start(0.05 + (0.08 * i), (t) -> {
                particle.scale.x += 0.06;
                particle.scale.y = particle.scale.x;
                particle.ID = 1;
            });
        }

        var i:Int = 0;
        while (alphaOff * i < 1)
        {
            new FlxTimer().start(0.05 + (alphaOff * i), (t) -> {
                particle.alpha -= alphaOff;
                particle.ID = 1;
            });

            i++;
        }
    }

    particles.forEachAlive((particle) -> {
        particle.updateHitbox();

        if (!particle.isOnScreen() && particle.ID == 1) {
            particles.remove(particle);
            addParticlePool(particle);
        }
    });
}
var alphaOff:Float = 0.005;