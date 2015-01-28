package com.genome2d.ui.element;

import com.genome2d.signals.GUIMouseSignal;
import flash.utils.Object;
import com.genome2d.ui.skin.GUISkinManager;
import com.genome2d.ui.layout.GUILayout;
import Xml.XmlType;
import com.genome2d.signals.GUIMouseSignal;
import com.genome2d.signals.GMouseSignalType;
import com.genome2d.signals.GMouseSignal;
import msignal.Signal.Signal1;
import com.genome2d.proto.GPrototypeFactory;
import com.genome2d.proto.IGPrototypable;
import com.genome2d.ui.skin.GUISkin;

@:access(com.genome2d.ui.layout.GUILayout)
@:access(com.genome2d.ui.skin.GUISkin)
@prototypeName("element")
class GUIElement implements IGPrototypable {
    @prototype public var mouseEnabled:Bool = true;

    public var visible:Bool = true;

    @prototype public var name:String = "GUIElement";

    private var g2d_currentClient:Dynamic;
    private var g2d_client:Dynamic;
    public function getClient():Dynamic {
        return (g2d_client != null) ? g2d_client : (parent != null) ? parent.getClient() : null;
    }
    public function setClient(p_value:Dynamic):Void {
        g2d_client = p_value;

        invalidateClient();
    }

    private function invalidateClient():Void {
        var newClient:Dynamic = getClient();
        if (newClient != g2d_currentClient) {
            if (g2d_mouseDown != "" && g2d_currentClient != null) {
                var mdf:GUIMouseSignal->Void = Reflect.field(g2d_currentClient, g2d_mouseDown);
                if (mdf != null) onMouseDown.remove(mdf);
            }
            g2d_currentClient = newClient;
            if (g2d_mouseDown != "" && g2d_currentClient != null) {
                var mdf:GUIMouseSignal->Void = Reflect.field(g2d_currentClient, g2d_mouseDown);
                if (mdf != null) onMouseDown.add(mdf);
            }

            for (i in 0...g2d_numChildren) {
                g2d_children[i].invalidateClient();
            }
        }
    }

    private var g2d_mouseDown:String;
    #if swc @:extern #end
    public var mouseDown(get,set):String;
    #if swc @:getter(mouseDown) #end
    inline private function get_mouseDown():String {
        return g2d_mouseDown;
    }
    #if swc @:setter(mouseDown) #end
    inline private function set_mouseDown(p_value:String):String {
        if (g2d_mouseDown != "" && g2d_currentClient != null) {
            var mdf:GUIMouseSignal->Void = Reflect.field(g2d_currentClient,g2d_mouseDown);
            if (mdf != null) onMouseDown.remove(mdf);
        }
        g2d_mouseDown = p_value;
        if (g2d_mouseDown != "" && g2d_currentClient != null) {
            var mdf:GUIMouseSignal->Void = Reflect.field(g2d_currentClient,g2d_mouseDown);
            if (mdf != null) onMouseDown.add(mdf);
        }
        return g2d_mouseDown;
    }


    private var g2d_value:Dynamic;
    #if swc @:extern #end
    public var value(get, set):Dynamic;
    #if swc @:getter(value) #end
    inline private function get_value():String {
        return g2d_value;
    }
    #if swc @:setter(value) #end
    inline private function set_value(p_value:Dynamic):Dynamic {
        g2d_value = p_value;
        if (Std.is(g2d_value,Xml)) {
            var xml:Xml = cast (g2d_value,Xml);
            var it:Iterator<Xml> = xml.elements();
            if (!it.hasNext()) {
                if (xml.firstChild() != null && xml.firstChild().nodeType == Xml.PCData) {
                    g2d_value = xml.firstChild().nodeValue;
                } else {
                    g2d_value = "";
                }
            } else {
                while (it.hasNext()) {
                    var childXml:Xml = it.next();
                    var child:GUIElement = getChildByName(childXml.nodeName);
                    if (child != null) {
                        if (childXml.firstChild() != null && childXml.firstChild().nodeType == Xml.PCData) {
                            child.value = childXml.firstChild().nodeValue;
                        } else {
                            child.value = childXml;
                        }
                    }
                }
            }
        } else {
            for (it in Reflect.fields(g2d_value)) {
                var child:GUIElement = getChildByName(it);
                if (child != null) child.value = Reflect.field(g2d_value, it);
            }
        }
        onValueChanged.dispatch(this);
        return g2d_value;
    }

    private var g2d_onValueChanged:Signal1<GUIElement>;
    #if swc @:extern #end
    public var onValueChanged(get, never):Signal1<GUIElement>;
    #if swc @:getter(onValueChanged) #end
    inline private function get_onValueChanged():Signal1<GUIElement> {
        return g2d_onValueChanged;
    }

    private var g2d_layout:GUILayout;
    #if swc @:extern #end
    @prototype public var layout(get, set):GUILayout;
    #if swc @:getter(layout) #end
    inline private function get_layout():GUILayout {
        return g2d_layout;
    }
    #if swc @:setter(layout) #end
    inline private function set_layout(p_value:GUILayout):GUILayout {
        g2d_layout = p_value;
        setDirty();
        return g2d_layout;
    }

    private var g2d_activeSkin:GUISkin;

    #if swc @:extern #end
    @prototype public var skinId(get, set):String;
    #if swc @:getter(skinId) #end
    inline private function get_skinId():String {
        return (g2d_skin != null) ? g2d_skin.id : "";
    }
    #if swc @:setter(skinId) #end
    inline
    private function set_skinId(p_value:String):String {
        if (skin != null) skin.remove(this);
        var s:GUISkin = GUISkinManager.getSkinById(p_value);
        skin = (s != null) ? s : null;
        return skinId;
    }

    private var g2d_skin:GUISkin;
    #if swc @:extern #end
    public var skin(get, set):GUISkin;
    #if swc @:getter(skin) #end
    inline private function get_skin():GUISkin {
        return g2d_skin;
    }
    #if swc @:setter(skin) #end
    inline private function set_skin(p_value:GUISkin):GUISkin {
        g2d_skin = (p_value != null) ? p_value.attach(this) : p_value;
        g2d_activeSkin = g2d_skin;

        setDirty();
        return g2d_skin;
    }

    private var g2d_dirty:Bool = true;
    private function setDirty():Void {
        g2d_dirty = true;
        if (g2d_parent != null) g2d_parent.setDirty();
    }

    private var g2d_anchorX:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorX(get, set):Float;
    #if swc @:getter(anchorX) #end
    inline private function get_anchorX():Float {
        return g2d_anchorX;
    }
    #if swc @:setter(anchorX) #end
    inline private function set_anchorX(p_value:Float):Float {
        g2d_anchorX = p_value;
        setDirty();
        return g2d_anchorX;
    }

    private var g2d_anchorY:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorY(get, set):Float;
    #if swc @:getter(anchorY) #end
    inline private function get_anchorY():Float {
        return g2d_anchorY;
    }
    #if swc @:setter(anchorY) #end
    inline private function set_anchorY(p_value:Float):Float {
        g2d_anchorY = p_value;
        setDirty();
        return g2d_anchorY;
    }

    private var g2d_anchorLeft:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorLeft(get, set):Float;
    #if swc @:getter(anchorLeft) #end
    inline private function get_anchorLeft():Float {
        return g2d_anchorLeft;
    }
    #if swc @:setter(anchorLeft) #end
    inline private function set_anchorLeft(p_value:Float):Float {
        g2d_anchorLeft = p_value;
        setDirty();
        return g2d_anchorLeft;
    }

    private var g2d_anchorTop:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorTop(get, set):Float;
    #if swc @:getter(anchorTop) #end
    inline private function get_anchorTop():Float {
        return g2d_anchorTop;
    }
    #if swc @:setter(anchorTop) #end
    inline private function set_anchorTop(p_value:Float):Float {
        g2d_anchorTop = p_value;
        setDirty();
        return g2d_anchorTop;
    }

    private var g2d_anchorRight:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorRight(get, set):Float;
    #if swc @:getter(anchorRight) #end
    inline private function get_anchorRight():Float {
        return g2d_anchorRight;
    }
    #if swc @:setter(anchorRight) #end
    inline private function set_anchorRight(p_value:Float):Float {
        g2d_anchorRight = p_value;
        setDirty();
        return g2d_anchorRight;
    }

    private var g2d_anchorBottom:Float = 0;
    #if swc @:extern #end
    @prototype public var anchorBottom(get, set):Float;
    #if swc @:getter(anchorBottom) #end
    inline private function get_anchorBottom():Float {
        return g2d_anchorBottom;
    }
    #if swc @:setter(anchorBottom) #end
    inline private function set_anchorBottom(p_value:Float):Float {
        g2d_anchorBottom = p_value;
        setDirty();
        return g2d_anchorBottom;
    }

    private var g2d_left:Float = 0;
    #if swc @:extern #end
    @prototype public var left(get, set):Float;
    #if swc @:getter(left) #end
    inline private function get_left():Float {
        return g2d_left;
    }
    #if swc @:setter(left) #end
    inline private function set_left(p_value:Float):Float {
        g2d_left = p_value;
        setDirty();
        return g2d_left;
    }

    private var g2d_top:Float = 0;
    #if swc @:extern #end
    @prototype public var top(get, set):Float;
    #if swc @:getter(top) #end
    inline private function get_top():Float {
        return g2d_top;
    }
    #if swc @:setter(top) #end
    inline private function set_top(p_value:Float):Float {
        g2d_top = p_value;
        setDirty();
        return g2d_top;
    }

    private var g2d_right:Float = 0;
    #if swc @:extern #end
    @prototype public var right(get, set):Float;
    #if swc @:getter(right) #end
    inline private function get_right():Float {
        return g2d_right;
    }
    #if swc @:setter(right) #end
    inline private function set_right(p_value:Float):Float {
        g2d_right = p_value;
        setDirty();
        return g2d_right;
    }

    public var g2d_bottom:Float = 0;
    #if swc @:extern #end
    @prototype public var bottom(get, set):Float;
    #if swc @:getter(bottom) #end
    inline private function get_bottom():Float {
        return g2d_bottom;
    }
    #if swc @:setter(bottom) #end
    inline private function set_bottom(p_value:Float):Float {
        g2d_bottom = p_value;
        setDirty();
        return g2d_bottom;
    }

    public var g2d_pivotX:Float = 0;
    #if swc @:extern #end
    @prototype public var pivotX(get, set):Float;
    #if swc @:getter(pivotX) #end
    inline private function get_pivotX():Float {
        return g2d_pivotX;
    }
    #if swc @:setter(pivotX) #end
    inline private function set_pivotX(p_value:Float):Float {
        g2d_pivotX = p_value;
        setDirty();
        return g2d_pivotX;
    }

    public var g2d_pivotY:Float = 0;
    #if swc @:extern #end
    @prototype public var pivotY(get, set):Float;
    #if swc @:getter(pivotY) #end
    inline private function get_pivotY():Float {
        return g2d_pivotY;
    }
    #if swc @:setter(pivotY) #end
    inline private function set_pivotY(p_value:Float):Float {
        g2d_pivotY = p_value;
        setDirty();
        return g2d_pivotY;
    }

    public var g2d_worldLeft:Float;
    public var g2d_worldTop:Float;
    public var g2d_worldRight:Float;
    public var g2d_worldBottom:Float;

    private var g2d_minWidth:Float = 0;
    private var g2d_variableWidth:Float = 0;
    public var g2d_finalWidth:Float = 0;

    private var g2d_preferredWidth:Float = 0;
    #if swc @:extern #end
    @prototype public var preferredWidth(get, set):Float;
    #if swc @:getter(preferredWidth) #end
    inline private function get_preferredWidth():Float {
        return g2d_preferredWidth;
    }
    #if swc @:setter(preferredWidth) #end
    inline private function set_preferredWidth(p_value:Float):Float {
        g2d_preferredWidth = p_value;
        setDirty();
        return g2d_preferredWidth;
    }

    private var g2d_minHeight:Float = 0;
    private var g2d_variableHeight:Float = 0;
    public var g2d_finalHeight:Float = 0;

    private var g2d_preferredHeight:Float = 0;
    #if swc @:extern #end
    @prototype public var preferredHeight(get, set):Float;
    #if swc @:getter(preferredHeight) #end
    inline private function get_preferredHeight():Float {
        return g2d_preferredHeight;
    }
    #if swc @:setter(preferredHeight) #end
    inline private function set_preferredHeight(p_value:Float):Float {
        g2d_preferredHeight = p_value;
        setDirty();
        return g2d_preferredHeight;
    }

    private var g2d_parent:GUIElement;
    #if swc @:extern #end
    public var parent(get, never):GUIElement;
    #if swc @:getter(parent) #end
    inline private function get_parent():GUIElement {
        return g2d_parent;
    }

    private var g2d_numChildren:Int = 0;
    #if swc @:extern #end
    public var numChildren(get, never):Int;
    #if swc @:getter(numChildren) #end
    inline private function get_numChildren():Int {
        return g2d_numChildren;
    }

    private var g2d_children:Array<GUIElement>;
    #if swc @:extern #end
    public var children(get, never):Array<GUIElement>;
    #if swc @:getter(children) #end
    inline private function get_children():Array<GUIElement> {
        return g2d_children;
    }


    public function new(p_skin:GUISkin = null) {
        g2d_onValueChanged = new Signal1<GUIElement>();

        if (p_skin != null) skin = p_skin;
    }

    public function isParent(p_element:GUIElement):Bool {
        if (p_element == g2d_parent) return true;
        if (g2d_parent == null) return false;
        return g2d_parent.isParent(p_element);
    }

    public function setRect(p_left:Float, p_top:Float, p_right:Float, p_bottom:Float):Void {
        var w:Float = p_right-p_left;
        var h:Float = p_bottom-p_top;

        if (g2d_parent != null) {
            var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorLeft;
            var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorRight;
            var worldAnchorTop:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorTop;
            var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorBottom;

            if (g2d_anchorLeft != g2d_anchorRight) {
                g2d_left = p_left - worldAnchorLeft;
                g2d_right = worldAnchorRight - p_right;
            } else {
                g2d_anchorX = p_left - worldAnchorLeft + w*g2d_pivotX;
            }

            if (g2d_anchorTop != g2d_anchorBottom) {
                g2d_top = p_top - worldAnchorTop;
                g2d_bottom = worldAnchorBottom - p_bottom;
            } else {
                g2d_anchorY = p_top - worldAnchorTop + h*g2d_pivotY;
            }
        } else {
            g2d_worldLeft = p_left;
            g2d_worldTop = p_top;
            g2d_worldRight = p_right;
            g2d_worldBottom = p_bottom;
            g2d_finalWidth = w;
            g2d_finalHeight = h;
        }

        g2d_preferredWidth = w;
        g2d_preferredHeight = h;

        setDirty();
    }

    public function addChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent == this) return;
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);
        g2d_children.push(p_child);
        g2d_numChildren++;
        p_child.g2d_parent = this;
        p_child.invalidateClient();
        setDirty();
    }

    public function addChildAt(p_child:GUIElement, p_index:Int):Void {
        if (g2d_children == null) g2d_children = new Array<GUIElement>();
        if (p_child.g2d_parent != null) p_child.g2d_parent.removeChild(p_child);
        g2d_children.insert(p_index,p_child);
        g2d_numChildren++;
        p_child.g2d_parent = this;
        p_child.invalidateClient();
        setDirty();
    }

    public function removeChild(p_child:GUIElement):Void {
        if (p_child.g2d_parent != this) return;
        g2d_children.remove(p_child);
        g2d_numChildren--;
        p_child.g2d_parent = null;
        p_child.invalidateClient();
        setDirty();
    }

    public function getChildAt(p_index:Int):GUIElement {
        return (p_index>=0 && p_index<g2d_numChildren) ? g2d_children[p_index] : null;
    }

    public function getChildByName(p_name:String):GUIElement {
        for (i in 0...g2d_numChildren) if (g2d_children[i].name == p_name) return g2d_children[i];
        return null;
    }

    public function getChildIndex(p_child:GUIElement):Int {
        return g2d_children.indexOf(p_child);
    }

    private function calculateWidth():Void {
        if (g2d_dirty) {
            if (g2d_layout != null) {
                g2d_layout.calculateWidth(this);
            } else {
                g2d_minWidth = g2d_activeSkin != null ? g2d_activeSkin.getMinWidth() : 0;

                for (i in 0...g2d_numChildren) {
                    g2d_children[i].calculateWidth();
                }
            }
        }
    }

    private function calculateHeight():Void {
        if (g2d_dirty) {
            if (g2d_layout != null) {
                g2d_layout.calculateHeight(this);
            } else {
                g2d_minHeight = g2d_activeSkin != null ? g2d_activeSkin.getMinHeight() : 0;

                for (i in 0...g2d_numChildren) {
                    g2d_children[i].calculateHeight();
                }
            }
        }
    }

    private function invalidateWidth():Void {
        if (g2d_dirty) {
            if (g2d_parent != null) {
                if (g2d_parent.g2d_layout == null) {
                    var worldAnchorLeft:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorLeft;
                    var worldAnchorRight:Float = g2d_parent.g2d_worldLeft + g2d_parent.g2d_finalWidth * g2d_anchorRight;
                    var w:Float = (g2d_preferredWidth > g2d_minWidth) ? g2d_preferredWidth : g2d_minWidth;

                    if (g2d_anchorLeft != g2d_anchorRight) {
                        g2d_worldLeft = worldAnchorLeft + g2d_left;
                        g2d_worldRight = worldAnchorRight - g2d_right;
                    } else {
                        g2d_worldLeft = worldAnchorLeft + g2d_anchorX - w * g2d_pivotX;
                        g2d_worldRight = worldAnchorLeft + g2d_anchorX + w * (1 - g2d_pivotX);
                    }

                    g2d_finalWidth = g2d_worldRight - g2d_worldLeft;
                }

                if (g2d_layout != null) {
                    g2d_layout.invalidateWidth(this);
                } else {
                    for (i in 0...g2d_numChildren) {
                        g2d_children[i].invalidateWidth();
                    }
                }
            } else {
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateWidth();
                }
            }
        }
    }

    private function invalidateHeight():Void {
        if (g2d_dirty) {
            if (g2d_parent != null) {
                if (g2d_parent.g2d_layout == null) {
                    var worldAnchorTop:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorTop;
                    var worldAnchorBottom:Float = g2d_parent.g2d_worldTop + g2d_parent.g2d_finalHeight * g2d_anchorBottom;
                    var h:Float = (g2d_preferredHeight > g2d_minHeight) ? g2d_preferredHeight : g2d_minHeight;
                    if (g2d_anchorTop != g2d_anchorBottom) {
                        g2d_worldTop = worldAnchorTop + g2d_top;
                        g2d_worldBottom = worldAnchorBottom - g2d_bottom;
                    } else {
                        g2d_worldTop = worldAnchorTop + g2d_anchorY - h * g2d_pivotY;
                        g2d_worldBottom = worldAnchorTop + g2d_anchorY + h * (1 - g2d_pivotY);
                    }
                    g2d_finalHeight = g2d_worldBottom - g2d_worldTop;
                }

                if (g2d_layout != null) {
                    g2d_layout.invalidateHeight(this);
                } else {
                    for (i in 0...g2d_numChildren) {
                        g2d_children[i].invalidateHeight();
                    }
                }
            } else {
                for (i in 0...g2d_numChildren) {
                    g2d_children[i].invalidateHeight();
                }
            }
        }
    }

    public function render():Void {
        if (visible) {
            if (g2d_activeSkin != null) g2d_activeSkin.render(g2d_worldLeft, g2d_worldTop, g2d_worldRight, g2d_worldBottom);

            for (i in 0...g2d_numChildren) {
                g2d_children[i].render();
            }
        }
    }

    public function getPrototype(p_prototypeXml:Xml = null):Xml {
        if (p_prototypeXml == null) p_prototypeXml = Xml.createElement("element");

        p_prototypeXml.set("anchorX", Std.string(anchorX));
        p_prototypeXml.set("anchorY", Std.string(anchorY));
        p_prototypeXml.set("anchorLeft", Std.string(anchorLeft));
        p_prototypeXml.set("anchorRight", Std.string(anchorRight));
        p_prototypeXml.set("anchorTop", Std.string(anchorTop));
        p_prototypeXml.set("anchorBottom", Std.string(anchorBottom));
        p_prototypeXml.set("pivotX", Std.string(pivotX));
        p_prototypeXml.set("pivotY", Std.string(pivotY));
        p_prototypeXml.set("left", Std.string(left));
        p_prototypeXml.set("right", Std.string(right));
        p_prototypeXml.set("top", Std.string(top));
        p_prototypeXml.set("bottom", Std.string(bottom));
        p_prototypeXml.set("preferredWidth", Std.string(preferredWidth));
        p_prototypeXml.set("preferredHeight", Std.string(preferredHeight));
        p_prototypeXml.set("name", name);
        p_prototypeXml.set("skinId", skinId);
        p_prototypeXml.set("mouseEnabled", Std.string(mouseEnabled));
        p_prototypeXml.set("visible", Std.string(visible));

        p_prototypeXml.set("mouseDown", mouseDown);

        if (layout != null) p_prototypeXml.addChild(layout.getPrototype());
        for (i in 0...g2d_numChildren) {
            p_prototypeXml.addChild(g2d_children[i].getPrototype());
        }
        return p_prototypeXml;
    }

    public function initPrototype(p_prototypeXml:Xml):Void {
        if (p_prototypeXml.exists("anchorX")) anchorX = Std.parseFloat(p_prototypeXml.get("anchorX"));
        if (p_prototypeXml.exists("anchorY")) anchorY = Std.parseFloat(p_prototypeXml.get("anchorY"));
        if (p_prototypeXml.exists("anchorLeft")) anchorLeft = Std.parseFloat(p_prototypeXml.get("anchorLeft"));
        if (p_prototypeXml.exists("anchorRight")) anchorRight = Std.parseFloat(p_prototypeXml.get("anchorRight"));
        if (p_prototypeXml.exists("anchorTop")) anchorTop = Std.parseFloat(p_prototypeXml.get("anchorTop"));
        if (p_prototypeXml.exists("anchorBottom")) anchorBottom = Std.parseFloat(p_prototypeXml.get("anchorBottom"));
        if (p_prototypeXml.exists("pivotX")) pivotX = Std.parseFloat(p_prototypeXml.get("pivotX"));
        if (p_prototypeXml.exists("pivotY")) pivotY = Std.parseFloat(p_prototypeXml.get("pivotY"));
        if (p_prototypeXml.exists("left")) left = Std.parseFloat(p_prototypeXml.get("left"));
        if (p_prototypeXml.exists("right")) right = Std.parseFloat(p_prototypeXml.get("right"));
        if (p_prototypeXml.exists("top")) top = Std.parseFloat(p_prototypeXml.get("top"));
        if (p_prototypeXml.exists("bottom")) bottom = Std.parseFloat(p_prototypeXml.get("bottom"));
        if (p_prototypeXml.exists("preferredWidth")) preferredWidth = Std.parseFloat(p_prototypeXml.get("preferredWidth"));
        if (p_prototypeXml.exists("preferredHeight")) preferredHeight = Std.parseFloat(p_prototypeXml.get("preferredHeight"));
        if (p_prototypeXml.exists("name")) name = p_prototypeXml.get("name");
        if (p_prototypeXml.exists("skinId")) skinId = p_prototypeXml.get("skinId");
        if (p_prototypeXml.exists("mouseEnabled")) mouseEnabled = (p_prototypeXml.get("mouseEnabled") != "false" && p_prototypeXml.get("mouseEnabled") != "0");
        if (p_prototypeXml.exists("visible")) visible = (p_prototypeXml.get("visible") != "false" && p_prototypeXml.get("visible") != "0");

        if (p_prototypeXml.exists("mouseDown")) mouseDown = p_prototypeXml.get("mouseDown");

        var it:Iterator<Xml> = p_prototypeXml.iterator();
        while (it.hasNext()) {
            var xml:Xml = it.next();
            if (xml.nodeType == Xml.PCData) {
                value = xml.nodeValue;
            } else if (xml.nodeType == Xml.Element) {
                var prototype:IGPrototypable = GPrototypeFactory.createPrototype(xml);
                if (Std.is(prototype, GUIElement)) {
                    addChild(cast prototype);
                } else if (Std.is(prototype, GUILayout)) {
                    layout = cast prototype;
                }
            }
        }
    }

    public function disposeChildren():Void {
        while (g2d_numChildren>0) {
            g2d_children[g2d_numChildren-1].dispose();
        }
    }

    public function dispose():Void {
        setDirty();
        if (g2d_parent != null) g2d_parent.removeChild(this);
    }

    /*******************************************************************************************************************
    *   MOUSE CODE
    *******************************************************************************************************************/
    private var g2d_onMouseDown:Signal1<GUIMouseSignal>;
    #if swc @:extern #end
    public var onMouseDown(get, never):Signal1<GUIMouseSignal>;
    #if swc @:getter(onMouseDown) #end
    inline private function get_onMouseDown():Signal1<GUIMouseSignal> {
        if (g2d_onMouseDown == null) g2d_onMouseDown = new Signal1(GUIMouseSignal);
        return g2d_onMouseDown;
    }

    private var g2d_onMouseUp:Signal1<GUIMouseSignal>;
    #if swc @:extern #end
    public var onMouseUp(get, never):Signal1<GUIMouseSignal>;
    #if swc @:getter(onMouseUp) #end
    inline private function get_onMouseUp():Signal1<GUIMouseSignal> {
        if (g2d_onMouseUp == null) g2d_onMouseUp = new Signal1(GUIMouseSignal);
        return g2d_onMouseUp;
    }

    private var g2d_onMouseMove:Signal1<GUIMouseSignal>;
    #if swc @:extern #end
    public var onMouseMove(get, never):Signal1<GUIMouseSignal>;
    #if swc @:getter(onMouseMove) #end
    inline private function get_onMouseMove():Signal1<GUIMouseSignal> {
        if (g2d_onMouseMove == null) g2d_onMouseMove = new Signal1(GUIMouseSignal);
        return g2d_onMouseMove;
    }

    private var g2d_onMouseOver:Signal1<GUIMouseSignal>;
    #if swc @:extern #end
    public var onMouseOver(get, never):Signal1<GUIMouseSignal>;
    #if swc @:getter(onMouseOver) #end
    inline private function get_onMouseOver():Signal1<GUIMouseSignal> {
        if (g2d_onMouseOver == null) g2d_onMouseOver = new Signal1(GUIMouseSignal);
        return g2d_onMouseOver;
    }

    private var g2d_onMouseOut:Signal1<GUIMouseSignal>;
    #if swc @:extern #end
    public var onMouseOut(get, never):Signal1<GUIMouseSignal>;
    #if swc @:getter(onMouseOut) #end
    inline private function get_onMouseOut():Signal1<GUIMouseSignal> {
        if (g2d_onMouseOut == null) g2d_onMouseOut = new Signal1(GUIMouseSignal);
        return g2d_onMouseOut;
    }

    private var g2d_onMouseClick:Signal1<GUIMouseSignal>;
    #if swc @:extern #end
    public var onMouseClick(get, never):Signal1<GUIMouseSignal>;
    #if swc @:getter(onMouseClick) #end
    inline private function get_onMouseClick():Signal1<GUIMouseSignal> {
        if (g2d_onMouseClick == null) g2d_onMouseMove = new Signal1(GUIMouseSignal);
        return g2d_onMouseClick;
    }

    private var g2d_mouseDownElement:GUIElement;
    private var g2d_mouseOverElement:GUIElement;

    public function processMouseSignal(p_captured:Bool, p_cameraX:Float, p_cameraY:Float, p_contextSignal:GMouseSignal):Bool {
        var i:Int = g2d_numChildren;
        while (i>0) {
            i--;
            p_captured = g2d_children[i].processMouseSignal(p_captured,p_cameraX,p_cameraY,p_contextSignal);
        }

        if (mouseEnabled) {
            if (!p_captured && p_cameraX>g2d_worldLeft && p_cameraX<g2d_worldRight && p_cameraY>g2d_worldTop && p_cameraY<g2d_worldBottom) {
                p_captured = true;
                g2d_dispatchMouseSignal(p_contextSignal.type, this, p_cameraX-g2d_worldLeft, p_cameraY-g2d_worldTop, p_contextSignal);
                if (g2d_mouseOverElement != this) {
                    g2d_dispatchMouseSignal(GMouseSignalType.MOUSE_OVER, this, p_cameraX-g2d_worldLeft, p_cameraY-g2d_worldTop, p_contextSignal);
                }
            } else {
                if (g2d_mouseOverElement == this) g2d_dispatchMouseSignal(GMouseSignalType.MOUSE_OUT, this, 0, 0, p_contextSignal);
            }
        }

        return p_captured;
    }

    private function g2d_dispatchMouseSignal(p_type:String, p_element:GUIElement, p_localX:Float, p_localY:Float, p_contextSignal:GMouseSignal):Void {
        if (mouseEnabled) {
            var mouseSignal:GUIMouseSignal = new GUIMouseSignal(p_type, this, p_element, p_localX, p_localY, p_contextSignal);

            switch (p_type) {
                case GMouseSignalType.MOUSE_DOWN:
                    g2d_mouseDownElement = p_element;
                    if (g2d_onMouseDown != null) g2d_onMouseDown.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_MOVE:
                    if (g2d_onMouseMove != null) g2d_onMouseMove.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_UP:
                    if (g2d_mouseDownElement == p_element && g2d_onMouseClick != null) {
                        var mouseClickSignal:GUIMouseSignal = new GUIMouseSignal(GMouseSignalType.MOUSE_UP, this, p_element, p_localX, p_localY, p_contextSignal);
                        g2d_onMouseClick.dispatch(mouseClickSignal);
                    }
                    g2d_mouseDownElement = null;
                    if (g2d_onMouseUp != null) g2d_onMouseUp.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_OVER:
                    g2d_mouseOverElement = p_element;
                    if (g2d_onMouseOver != null) g2d_onMouseOver.dispatch(mouseSignal);
                case GMouseSignalType.MOUSE_OUT:
                    g2d_mouseOverElement = null;
                    if (g2d_onMouseOut != null) g2d_onMouseOut.dispatch(mouseSignal);
            }
        }

        if (parent != null) parent.g2d_dispatchMouseSignal(p_type, p_element, p_localX, p_localY, p_contextSignal);
    }
}
