using Sandbox;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerrorTown;

namespace MinecraftExperience;

public class AutoJumpComponent : SimulatedComponent
{
	public override void BuildInput()
	{
		base.BuildInput();  
		var startpos = Entity.Position;
		startpos += Vector3.Up * 40;
		var wishvel = new Vector3(Input.AnalogMove.x, Input.AnalogMove.y, 0);
		wishvel *= Entity.ViewAngles.WithPitch(0).WithYaw(MathF.Round(Entity.ViewAngles.yaw/90) * 90).ToRotation();

		startpos += wishvel * 48;
		var endpos = startpos;
		endpos += Vector3.Up * -1;
		var tr = Trace.Ray(startpos, endpos).StaticOnly().Run();
		DebugOverlay.Line(tr.StartPosition, tr.EndPosition);
		if (tr.Hit)
		{
			Input.SetAction("Jump", true);
		}
	}
}
