import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.math.FlxRect;
import flixel.FlxObject;
import flixel.util.FlxCollision;
import openfl.text.TextField;
import openfl.display.Sprite;

var weeks:Array<Dynamic> = [
    {
        name: "Last Breath",
        id: "last-breath",
        sprite: null,
        chars: ['dad', 'gf', 'bf'],
        songs: [{
            name: "Slacker",
            hide: true
        }],
        difficulties: ['hard']
    }
];

var gradient:FlxSprite;
var header:FlxSprite;
var particles:FlxTypedGroup<FlxSprite>;
var buttons:FlxTypedGroup<FlxSprite>;
var texts:FlxTypedGroup<FlxText>;

// Button list huhh
var list = ['last_breath', 'last_breath', 'last_breath'];

var lastSelect = -1;
var curSelect = -1;
// Cool down for intro anim
var cooldown:Float = 0;
// Gradient intro scale lerp
var scaleLerp = 0;
// Particle pooling
var pools = [];

var trans = false;
var itemTrans = false;

// if pressed a chapter
var wasPressed = false;

var sannes:FlxSprite;
var sannesHidder:FlxSprite;

function formatTitle(n:String)
{
    var result = '';

    for (a in n.split('_'))
    {
        result += a.toUpperCase() + ' ';
    }

    return result;
}

function create()
{
    trace('[LNOF] Phase Selection');

    gradient = new FlxSprite();
    gradient.loadGraphic(Paths.image('ut/menu/gradient'));
    gradient.scrollFactor.set(0.3, 0.3);
    gradient.color = FlxColor.fromString('#0A8D8A');
    add(gradient);

    sannes = new FlxSprite().loadGraphic(Paths.image('ut/menu/sussy'));
    sannes.scrollFactor.set();
    sannes.scale.set(0.9, 0.9);
    sannes.updateHitbox();
    add(sannes);

    sannesHidder = new FlxSprite();
    sannesHidder.makeGraphic(sannes.width - (35 * sannes.scale.x), sannes.height - (24 * sannes.scale.y), FlxColor.BLACK);
    sannesHidder.scrollFactor.set();
    sannesHidder.updateHitbox();
    add(sannesHidder);

    particles = new FlxTypedGroup(25);
    add(particles);

    buttons = new FlxTypedGroup();
    add(buttons);
    
    texts = new FlxTypedGroup();
    add(texts);

    header = new FlxText();
    header.text = 'select the chapter';
    header.setFormat(Paths.font("undertale-cool.ttf"), 48, 0xFFFFFF);
    header.x = FlxG.width / 2 - header.width / 2;
    header.y = header.height * -2;
    header.scrollFactor.set(0.6, 0.6);
    add(header);

    for (i in 0...list.length)
    {
        var button:FlxSprite = new FlxSprite();
        button.loadGraphic(Paths.image('ut/phases/items/' + list[i]));
        button.scale.set(0.7, 0.7);
        button.x = FlxG.width * 0.0615 + (FlxG.width * 0.3 * i);
        button.y = -button.height;
        button.ID = i;
        button.scrollFactor.set(0.4 + (0.065 * i), 0.4 + (0.065 * i));
        button.updateHitbox();
        buttons.add(button);

        var text:FlxText = new FlxText();
        text.text = formatTitle(list[i]);
        text.setFormat(Paths.font("undertale-cool.ttf"), 32, 0xFFFFFF);
        text.ID = i;
        text.scrollFactor.set(0.4 + (0.065 * i), 0.4 + (0.065 * i));
        texts.add(text);
    }
    
    new FlxTimer().start(Conductor.crochet / 1000, (t) -> {
        trans = true;
    });
    new FlxTimer().start(Conductor.crochet / 450, (t) -> {
        itemTrans = true;
    });

    FlxG.mouse.visible = true;

    final fp = Main.framerateSprite.fpsCounter;
    final mc = Main.framerateSprite.memoryCounter;
    final cne = Main.framerateSprite.codenameBuildField;

    for (text in [fp.fpsNum, fp.fpsLabel, mc.memoryText, mc.memoryPeakText, cne])
    {
        text.mouseEnabled = false;
    }
}
function update(elapsed)
{
    sannesHidder.visible = !FlxG.mouse.overlaps(sannes);

    if (sannesHidder.visible && FlxG.mouse.justPressed && FlxG.mouse.overlaps(sannes))
    {
        trace('sannes');
    }

    updateSelection();

    if (!wasPressed) {
        // keeping this while i figure out error when using `usingMouse`
        // if (1 == 0)
        // was easy to fix (2 weeks later lol)
        if (!mouse)
        {
            // Infinite path cuz is good
            // https://gamedev.stackexchange.com/questions/43691/how-can-i-move-an-object-in-an-infinity-or-figure-8-trajectory
            final scale = 2 / (3 - FlxMath.fastCos(2 * curMeasureFloat));
            camera.scroll.x = scale * (FlxMath.fastCos(curMeasureFloat * Math.PI) * 12);
            camera.scroll.y = scale * ((FlxMath.fastSin(curMeasureFloat * 2 * Math.PI) * 0.5) * 12);
        } else {
            camera.scroll.x = FlxG.mouse.x * -0.0325;
            camera.scroll.y = FlxG.mouse.y * -0.0325;
        }
    } else {
        final lerpRatio = 0.125 / 2 * (60 * elapsed);
        final item = buttons.members[curSelect];
        gradient.alpha = FlxMath.lerp(gradient.alpha, 0, lerpRatio);
        particles.forEach(particle -> {
            particle.acceleration.y = FlxMath.lerp(particle.acceleration.y, 4000, lerpRatio);
            if (particle.acceleration.y < 4000 && particle.y > FlxG.height) particle.kill();
        });

        if (elapsedPressed >= 0.5)
        {
            camera.zoom = FlxMath.lerp(camera.zoom, 1.6, lerpRatio);
            if (!followed)
            {      
                wasPressed = true;
                camera.follow(new FlxObject(item.getMidpoint().x, item.getMidpoint().y), FlxCameraFollowStyle.NO_DEAD_ZONE, .5);
                followed = true;
            }
        }
        if (elapsedPressed >= 1.5 && !play)
        {
            PlayState.loadWeek(weeks[curSelect], 'hard');
            FlxG.switchState(new PlayState());

            play = true;
        }
        elapsedPressed += elapsed;
    }

    lastSelect = curSelect;

    final lerpRatio = 0.125 / 2 * (60 * elapsed);

    texts.forEach(text -> {
        final item = buttons.members[text.ID];
        final scaleDiff = item.scale.x - 0.6;
        text.x = item.x + item.width / 2 - text.width / 2;

        // why that much ?? 600?? wtff -theo
        text.y = item.y + item.height - 10 - (scaleDiff * -365);
        text.scale.set(0.9 + scaleDiff * 1.5, 0.9 + scaleDiff * 1.5);
        text.alpha = !wasPressed ? item.alpha : FlxMath.lerp(text.alpha, 0, lerpRatio);
        text.updateHitbox();
    });

    if (!trans) {
        gradient.scale.y = 0;
        return;
    }

    header.y = FlxMath.lerp(header.y, FlxG.height * 0.06, .05);
    scaleLerp = FlxMath.lerp(scaleLerp, 1, .05);

    gradient.scale.y = scaleLerp + (Math.abs(FlxMath.fastSin(Conductor.curBeatFloat * Math.PI) * 0.5)) * scaleLerp;
    gradient.updateHitbox();
    gradient.y = FlxG.height - gradient.height;
    gradient.screenCenter(FlxAxes.X);

    updateParticles(elapsed);
}

var elapsedPressed:Float = 0;
var followed = false;

var play = false;
var mouse = false;

function updateSelection()
{
    if (FlxG.mouse.justMoved && !mouse)
        mouse = true;

    if (controls.LEFT_P || controls.RIGHT_P)
    {
        CoolUtil.playMenuSFX(0, 2);
        mouse = false;
    }

    if (controls.LEFT_P) curSelect -= 1;
    if (controls.RIGHT_P) curSelect += 1;

    if (controls.BACK)
        FlxG.switchState(new MainMenuState());


    // Bound selection
    curSelect = (curSelect < 0 ? curSelect + buttons.members.length : curSelect) % buttons.members.length;

    final lerpRatio = 0.125 * 60 * FlxG.elapsed;

    buttons.forEach(item -> {
        final floatShit = FlxMath.fastSin((curMeasureFloat + item.ID / 2) * Math.PI) * 10;
        final selected:Bool = FlxG.mouse.overlaps(item) || (!mouse && curSelect == item.ID);

        if (itemTrans)
            item.y = FlxMath.lerp(
                item.y,
                FlxG.height / 2.075 - item.height / 2 + floatShit +
                (wasPressed && item.ID != curSelect ? FlxG.height : 0),
                0.05 + (0.01 * item.ID)
            );

        item.scale.x = item.scale.y = FlxMath.lerp(item.scale.x, selected ? 0.7 : 0.67, lerpRatio);
        item.alpha = FlxMath.lerp(item.alpha, selected ? 1 : 0.8, lerpRatio);

        if (selected && (controls.ACCEPT || FlxG.mouse.justPressed) && !wasPressed)
        {
            wasPressed = true;
            CoolUtil.playMenuSFX(1, 0.7);
        }
        item.loadGraphic(Paths.image('ut/phases/items/' + list[item.ID] + (selected ? '_selected' : '')));
        item.updateHitbox();

        // For mouse selection
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
    if (FlxG.random.bool(4.275)) {
        var particle = getParticle();
        particle.loadGraphic(Paths.image('ut/menu/particle'));
        particle.scale.set(0.1275, 0.1275);
        particle.x = FlxG.width * 0.05 + FlxG.width * 0.85 * Math.random();
        particle.y = FlxG.height + 20;
        particle.velocity.y = -450;
        particle.alpha = 0.8;
        particle.ID = 0;

        particle.color = FlxColor.fromString('#67D4D0');

        particle.scrollFactor.set(0.4, 0.4);
        particles.add(particle);

        var i:Int = 0;
        while (alphaOff * i < 1)
        {
            new FlxTimer().start(0.1 + (alphaOff * i), (t) -> {
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