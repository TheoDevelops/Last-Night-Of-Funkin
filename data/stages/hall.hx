import funkin.backend.shaders.FunkinShader;

var back:FlxSprite;
var bPillars:FlxSprite;
var shading:FlxSprite;
var fPillars:FlxSprite;

function create()
{

    var add:FlxSprite->Void = (obj) -> {
        insert(members.indexOf(boyfriend), obj);
    }

    back = new FlxSprite(-100, 100);
    back.loadGraphic(Paths.image('hall/back'));
    back.scrollFactor.set(0.94, 1);
    add(back);

    bPillars = new FlxSprite(0, 100);
    bPillars.loadGraphic(Paths.image('hall/backPillars'));
    bPillars.scrollFactor.set(0.95, 1);
    add(bPillars);

    shading = new FlxSprite(-100, 100);
    shading.loadGraphic(Paths.image('hall/shading'));
    shading.scrollFactor.set(0.94, 1);
    shading.blend = "multiply";
    add(shading);

    fPillars = new FlxSprite(-525);
    fPillars.loadGraphic(Paths.image('hall/frontPillars'));
    fPillars.scrollFactor.set(0.3, 0.6);
    fPillars.scale.set(2.2, 2.2);
    fPillars.updateHitbox();
}
function postCreate()
{
    add(fPillars);
}