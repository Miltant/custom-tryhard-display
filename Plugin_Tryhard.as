#name "Additional Tryhard Options"
#author "MiLTanT"


// The options are an array of UILabel, stored in the settings as a JSON

[Setting name="Options as JSON" multiline description="\\$fffYou probably \\$f00DON'T\\$fff want to edit this. See the \\$d00Tryhard \\$dddOptions \\$ffffor a visual editor."]
string labels_JSON = """{ "options": [ 
{ "text": "gain: %roxgain%", "color": {"r": 1, "v": 1, "b": 1, "auto": true}, "position": { "x": 0.295, "y": 0.98 }, "size": 16 },
{ "text": "gain: %stamgain% amount: #stam/#stammax", "color": {"r": 1, "v": 1, "b": 1, "auto": true}, "position": { "x": 0.595, "y": 0.98 }, "size": 16 }
] }""";


array<UILabel> labels;

class UILabel
{
   string text = "New label";
   
   vec3 color = vec3(1, 0, 0);
   bool auto_color = true;
   float font_size = 30.0f;
   
   vec2 position = vec2(0.5f, 0.5f);
}



// Important reference variables

auto @app = cast<CTrackMania>(GetApp()); // root node for interacting with maniaplanet

auto @option_window = OptionsWindow(); // the option window, responsible for drawing itself


class OptionsWindow
{
   bool visible = false;
   private uint current_label = 0;
   
   void display_window() // only to be used in the RenderInterface() entry point
   {
      UI::Begin("Additional \\$f00Tryhard\\$z Options");
      {
         if (labels.IsEmpty())
         {
	         if (UI::Button("\\$fffAdd a label"))
		         {
		            labels.InsertLast(UILabel());
		            current_label = labels.Length - 1;
		         }
         }
         else
         {
            UI::Text("Select a label to edit:");
            
				UI::SameLine();
				
				
				// ui element are identified by their label, an empty string as first argument makes thee box unclickable
	         if (UI::BeginCombo("\\$000", "\\$ffa" + labels[current_label].text, UI :: ComboFlags :: None))
	         {
	            for (uint i = 0; i < labels.Length; ++i)
	            {
	            	// `invisible_uint()` generates a unique string from the i
	               if (UI::Selectable("\\$ffa" + labels[i].text + invisible_uint(i), i==current_label))
	               {
	               	current_label = i;
	               }
	            }
	            
		         UI::Separator();
		         
		         if (UI::Button("Add a label"))
		         {
		            labels.InsertLast(UILabel());
		            current_label = labels.Length - 1;
		         }
		         
		         UI::SameLine();
		         
		         if (UI::Button("Remove the selected label"))
		         {
		            labels.RemoveAt(current_label);
		            
		            if (current_label >= labels.Length)
		            {
		            	current_label = labels.Length - 1;
		            }
		         }
		         
	         	UI::EndCombo();
	         }
	         
	         if (!labels.IsEmpty())
	         {
		         UI::Separator();
		         UI::Text("Font color:");
		         if (!(labels[current_label].auto_color = UI::Checkbox("Use the player's color", labels[current_label].auto_color)))
		            labels[current_label].color = UI::InputColor3("", labels[current_label].color);
		         
		         UI::Separator();
		         UI::Text("Font size:");
		         labels[current_label].font_size = Math::Clamp(UI::InputFloat("px", labels[current_label].font_size, 0.1f), 0.f, 1000.f);
		         
		         UI::Separator();
		         UI::Text("Position:");
		         labels[current_label].position.x = Math::Clamp(UI::InputFloat("% of X", labels[current_label].position.x * 100, 0.01f) / 100, 0.f, 1.f);
		         labels[current_label].position.y = Math::Clamp(UI::InputFloat("% of Y", labels[current_label].position.y * 100, 0.01f) / 100, 0.f, 1.f);
		         
		         UI::Separator();
		         UI::Text("Text:");
		         labels[current_label].text = UI::InputText("", labels[current_label].text);
		         UI::Text("Available placeholders:\n"
		                  "   -   \\$f00%stamgain\\$z : stamina regen (% of default value)\n"
		                  "   -   \\$f00%stam\\$z | \\$f00#stam\\$z : current stamina amount (100% = 3600)\n"
		                  "   -   \\$f00%stammax\\$z | \\$f00#stammax\\$z : full stamina amount (100% = 3600)");
		         
		         UI::Text("   -   \\$f00%roxgain\\$z | \\$f00#roxgain\\$z : rocket regen (100% = 0.63Hz))");
		         
               UI::Text("   -   \\$f00#speed\\$z : player velocity\n"
                        "   -   \\$f00#hspeed\\$z : player horizontal velocity (North/South/East/West)\n"
                        "   -   \\$f00#vspeed\\$z : player vertical velocity (Up/Down)\n");

               UI::Text("   -   \\$f00#pos\\$z : player position\n"
                        "   -   \\$f00#posX\\$z | \\$f00#posY\\$z | \\$f00#posZ\\$z : player position individual coordinates\n"
                        "   -   \\$f00#dpos/dt\\$z | \\$f00#dhpos/dt\\$z | \\$f00#dvpos/dt\\$z : instantaneous \"velocity\"\n"
                        "   -   \\$f00#dpos/dt2\\$z | \\$f00#dhpos/dt2\\$z | \\$f00#dvpos/dt2\\$z : instantaneous \"acceleration\"");
               
               UI::Text("   -   \\$f00#.speed\\$z | \\$f00#.pos\\$z | etc. : speed or position with higher accuracy\n");
	         }
	      }
	   }
      UI::End();
      
      // I don't really know how to tell if something changed :/
      update_JSON_from_array();
   }
}



// Helper functions

void update_array_from_JSON() // side effect: labels
{
   try // a global try...catch is dirty, but every line can go wrong if the JSON is corrupted...
   {
      Json::Value root = Json::Parse(labels_JSON); // we only want the "options" property

      Json::Value array_JSON = root["options"];

      for (uint i = 0; i < array_JSON.Length; ++i)
      {
         Json::Value label_JSON = array_JSON[i];
         
         UILabel label = UILabel();
         
         label.text = label_JSON["text"];
         label.font_size = label_JSON["size"];
         
         
         Json::Value label_color = label_JSON["color"];
         label.color = vec3(label_color["r"], label_color["v"], label_color["b"]);
         label.auto_color = label_color["auto"];
         
         
         label.position = vec2(label_JSON["position"]["x"], label_JSON["position"]["y"]);
         
         labels.InsertLast(label);
      }
   }
   catch // ...and the handling is the same, I'm not trying anything fancy
   {
      show_error("The options JSON string seams corrupted. Please try to fix it, reinstal the script to reset its default settings, or contact MiLTanT#7489 on Discord.");
   }
}


void update_JSON_from_array()
{
   Json::Value root = Json::Object();
   Json::Value array_JSON = Json::Array();
   
   for (uint i = 0; i < labels.Length; ++i)
   {
      Json::Value label_JSON = Json::Object();
      
      Json::Value label_color = Json::Object();
      label_color["r"] = labels[i].color.x;
      label_color["v"] = labels[i].color.y;
      label_color["b"] = labels[i].color.z;
      label_color["auto"] = labels[i].auto_color;
      
      label_JSON["color"] = label_color;
      
      Json::Value label_position = Json::Object();
      label_position["x"] = labels[i].position.x;
      label_position["y"] = labels[i].position.y;
      
      label_JSON["position"] = label_position;
      
      label_JSON["text"] = labels[i].text;
      label_JSON["size"] = labels[i].font_size;
      
      array_JSON.Add(label_JSON);
   }
   
   root["options"] = array_JSON;
   
   labels_JSON = Json::Write(root);
}


vec4 get_rgb(float hue)
{
   vec4 rgb = vec4(0, 0, 0, 1); // actually rgba
   
   for (uint i = 0; i < 3; ++i)  // mafs stonks
   {
      float k = (-6 * i * i + 14 * i + hue * 12) % 12;
      float a = k - 3;
      float b = -1 * k + 9;
      
      float comp = 0.6 - (0.4 * Math::Max(0.0f - 1.0f, Math::Min(Math::Min(a, b), 1.0f)));
      
      if (i == 0) rgb.x = comp;
      if (i == 1) rgb.y = comp;
      if (i == 2) rgb.z = comp;
   }
   
   return rgb;
}

string invisible_uint(uint i)
{
	if (i == 0) return "";
	
	if (i < 10) return "\\$00" + i;
	
	if (i < 100) return "\\$0" + i;
	
	if (i < 1000) return "\\$" + i;
	
	uint next = i / 1000;
	return invisible_uint(next) + invisible_uint(next - i);
}

void show_error(string text)
{
   UI::ShowNotification("Additional \\$f00Tryhard\\$z Options", text, 15000);
}


vec4 player_color = vec4(0, 0, 0, 1);

vec3 position_cache = vec3(0, 0, 0);
vec3 velocity_cache = vec3(0, 0, 0);
vec3 velocity_cache_2 = vec3(0, 0, 0);
vec3 acceleration_cache = vec3(0, 0, 0);

void Update(float dt)
{
   dt /= 1000;

   if (dt > 0)
   {
      if ( app is null
        || app.CurrentPlayground is null
        || app.CurrentPlayground.GameTerminals[0].GUIPlayer is null )
         return;
      
      CSmScriptPlayer@ sm_script = cast<CSmPlayer>(app.CurrentPlayground.GameTerminals[0].GUIPlayer).ScriptAPI;

      velocity_cache_2 = velocity_cache;

      velocity_cache = vec3(
         (sm_script.Position.x - position_cache.x) / dt,
         (sm_script.Position.y - position_cache.y) / dt,
         (sm_script.Position.z - position_cache.z) / dt
      );

      acceleration_cache = vec3(
         (velocity_cache.x - velocity_cache_2.x) / dt,
         (velocity_cache.y - velocity_cache_2.y) / dt,
         (velocity_cache.z - velocity_cache_2.z) / dt
      );

      position_cache = sm_script.Position;
   }
}



// Entry points

void RenderMenuMain() // check-uncheck `option_window.visible` ...
{
   if (option_window.visible)
   {
      if (UI::MenuItem("Hide \\$f00Tryhard\\$z Options", "", option_window.visible, true))
         option_window.visible = false;
   }
   else
   {
      if (UI::MenuItem("Show \\$f00Tryhard\\$z Options", "", option_window.visible, true))
         option_window.visible = true;
   }    
}
void RenderInterface() // ... and, if it's checked, draw the OptionsWindow
{
   if (option_window.visible)
       option_window.display_window();
}


void Main() { update_array_from_JSON(); }
void OnSettingsChanged() { update_array_from_JSON(); }


void Render() // every frame, display the UILabels in 2 steps
{
   // 1) retrieve the player's information
   
   // asserts a player is playing and has his gui displayed on the screen
   if ( app is null
     || app.CurrentPlayground is null
     || app.CurrentPlayground.GameTerminals[0].GUIPlayer is null )
      return;
   
   // the player as a social body: nick, color, region, planets count...
   CSmPlayer@ sm_player = cast<CSmPlayer>(app.CurrentPlayground.GameTerminals[0].GUIPlayer);
   player_color = get_rgb(sm_player.LinearHue);
   
   // the player as a gaming element: velocity, position, stamina...
   CSmScriptPlayer@ sm_script = sm_player.ScriptAPI;

   
   // 2) iterate throught the UILabels and print them!
   
   for (uint i = 0; i < labels.Length; ++i)
   {
      UILabel label = labels[i];
      string text = label.text;
      
      // format label text's placeholders
      
      
      if (text.IndexOf("rox") > -1)
      {
         text = Regex::Replace(text, "%roxgain", "" + sm_script.AmmoGain * 100);
         text = Regex::Replace(text, "#roxgain", "" + sm_script.AmmoGain * 1.58); //  ?__?
      }
      
      if (text.IndexOf("stammax") > -1)
      {
         text = Regex::Replace(text, "%stammax", "" + Math::Floor(sm_script.StaminaMax * 1000) / 10);
         text = Regex::Replace(text, "#stammax", "" + sm_script.StaminaMax * 3600);
      }
      if (text.IndexOf("%stamgain") > -1)
      {
         text = Regex::Replace(text, "%stamgain", "" + Math::Floor(sm_script.StaminaGain * 1000) / 10);
      }
      
      if (text.IndexOf("stam") > -1) // the two previous tokens contain this one!..
      {
         text = Regex::Replace(text, "%stam", "" + Math::Floor(sm_script.Stamina / sm_script.StaminaMax / 3.6f) / 10);
         text = Regex::Replace(text, "#stam", "" + sm_script.Stamina);
      }
      
      if (text.IndexOf("speed") > -1)
      {
         if (text.IndexOf("hspeed") > -1)
         {
            float hspeed = Math::Sqrt(sm_script.Velocity.x*sm_script.Velocity.x + sm_script.Velocity.z*sm_script.Velocity.z);
            text = Regex::Replace(text, "#.hspeed", "" + hspeed * 3.6f);
            text = Regex::Replace(text, "#hspeed", "" + Math::Floor(hspeed * 36) / 10);
         }
         if (text.IndexOf("vspeed") > -1)
         {
            text = Regex::Replace(text, "#.vspeed", "" + sm_script.Velocity.y * 3.6f);
            text = Regex::Replace(text, "#vspeed", "" + Math::Floor(sm_script.Velocity.y * 36) / 10);
         }

         if (text.IndexOf("speed") > -1) // the two previous tokens contain this one!..
         {
            text = Regex::Replace(text, "#.speed", "" + sm_script.Speed * 3.6f);
            text = Regex::Replace(text, "#speed", "" + Math::Floor(sm_script.Speed * 36) / 10);
         }
      }

      if (text.IndexOf("pos/dt") > -1)
      {
         if (text.IndexOf("dhpos/dt2") > -1)
         {
            float hspeed = Math::Sqrt(acceleration_cache.x*acceleration_cache.x + acceleration_cache.z*acceleration_cache.z);

            text = Regex::Replace(text, "#.dhpos/dt2", "" + hspeed);
            text = Regex::Replace(text, "#dhpos/dt2", "" + Math::Floor(hspeed * 36) / 10);
         }

         if (text.IndexOf("dhpos/dt") > -1)
         {
            float hspeed = Math::Sqrt(velocity_cache.x*velocity_cache.x + velocity_cache.z*velocity_cache.z);

            text = Regex::Replace(text, "#.dhpos/dt", "" + hspeed);
            text = Regex::Replace(text, "#dhpos/dt", "" + Math::Floor(hspeed * 36) / 10);
         }
         if (text.IndexOf("dvpos/dt2") > -1)
         {
            text = Regex::Replace(text, "#.dvpos/dt2", "" + acceleration_cache.y * 3.6f);
            text = Regex::Replace(text, "#dvpos/dt2", "" + Math::Floor(acceleration_cache.y * 36) / 10);
         }
         if (text.IndexOf("dvpos/dt") > -1)
         {
            text = Regex::Replace(text, "#.dvpos/dt", "" + velocity_cache.y * 3.6f);
            text = Regex::Replace(text, "#dvpos/dt", "" + Math::Floor(velocity_cache.y * 36) / 10);
         }

         if (text.IndexOf("dpos/dt2") > -1)
         {
            float speed = Math::Sqrt(acceleration_cache.x*acceleration_cache.x + acceleration_cache.y*acceleration_cache.y + acceleration_cache.z*acceleration_cache.z);

            text = Regex::Replace(text, "#.dpos/dt2", "" + speed * 3.6f);
            text = Regex::Replace(text, "#dpos/dt2", "" + Math::Floor(speed * 36) / 10);
         }

         if (text.IndexOf("dpos/dt") > -1)
         {
            float speed = Math::Sqrt(velocity_cache.x*velocity_cache.x + velocity_cache.y*velocity_cache.y + velocity_cache.z*velocity_cache.z);

            text = Regex::Replace(text, "#.dpos/dt", "" + speed * 3.6f);
            text = Regex::Replace(text, "#dpos/dt", "" + Math::Floor(speed * 36) / 10);
         }
      }



      if (text.IndexOf("pos") > -1)
      {
         if (text.IndexOf("posX") > -1)
         {
            text = Regex::Replace(text, "#.posX", "" + sm_script.Position.x);
            text = Regex::Replace(text, "#posX", "" + Math::Floor(sm_script.Position.x * 10) / 10);
         }
         if (text.IndexOf("posY") > -1)
         {
            text = Regex::Replace(text, "#.posY", "" + sm_script.Position.y);
            text = Regex::Replace(text, "#posY", "" + Math::Floor(sm_script.Position.y * 10) / 10);
         }
         if (text.IndexOf("posZ") > -1)
         {
            text = Regex::Replace(text, "#.posZ", "" + sm_script.Position.z);
            text = Regex::Replace(text, "#posZ", "" + Math::Floor(sm_script.Position.z * 10) / 10);
         }

         if (text.IndexOf("#.pos") > -1)
         {
            text = Regex::Replace(text, "#.pos", "<" + sm_script.Position.x + ", " + sm_script.Position.y + ", " + sm_script.Position.z + ">");
         }
         if (text.IndexOf("#pos") > -1)
         {
            text = Regex::Replace(text, "#pos", "<" + Math::Floor(sm_script.Position.x * 10) / 10 + ", " + Math::Floor(sm_script.Position.y * 10) / 10 + ", " + Math::Floor(sm_script.Position.z * 10) / 10 + ">");
         }
      }
      
      Draw::DrawString(
         vec2(Draw::GetWidth() * label.position.x, Draw::GetHeight() * label.position.y),
         label.auto_color ? player_color : vec4(label.color.x, label.color.y, label.color.z, 1),
         text, null, label.font_size
      );
   }
}
