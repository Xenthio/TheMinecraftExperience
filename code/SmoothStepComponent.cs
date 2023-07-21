using Sandbox;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TerrorTown;

namespace MinecraftExperience;

public partial class SmoothStepComponent : SimulatedComponent
{
	[Net] ModelEntity Stool { get; set; }
	protected override void OnActivate()
	{
		base.OnActivate();
		if (Game.IsServer)
		{
			Stool = new ModelEntity();
			Stool.SetModel("models/clipmodel.vmdl");
			Stool.SetupPhysicsFromModel(PhysicsMotionType.Keyframed);
			Stool.Tags.Add("solid");
			Stool.Tags.Add("nomovewith");
			Stool.Tags.Add("nopush");
			Stool.Owner = Entity;
		}
	}
	public override void Simulate(IClient cl)
	{
		base.Simulate(cl);
		if (Input.AnalogMove.Length <= 0)
		{
			Stool.Position = new Vector3(0, 0, -100000);
			return;
		}
		var initialtrdown = Trace.Ray(Entity.Position + (Vector3.Up * 24), Entity.Position + (Vector3.Down * 48)).StaticOnly().Run();
		if (!initialtrdown.Hit)
		{
			Stool.Position = new Vector3(0, 0, -100000);
			return;
		}

		var wishvel = new Vector3(Input.AnalogMove.x, Input.AnalogMove.y, 0);
		wishvel *= Entity.ViewAngles.WithPitch(0).WithYaw(MathF.Round(Entity.ViewAngles.yaw / 45) * 45).ToRotation();
		//wishvel = wishvel.EulerAngles.WithYaw((MathF.Round(wishvel.EulerAngles.yaw / 90) * 90)).Forward;

		var startpos = initialtrdown.EndPosition;
		startpos += Vector3.Up * 1;
		var endpos = startpos;
		endpos += wishvel * 64;
		var tr = Trace.Ray(startpos, endpos).StaticOnly().Run();
		//DebugOverlay.Line(tr.StartPosition, tr.EndPosition);
		if (!tr.Hit)
		{
			Stool.Position = new Vector3(0, 0, -100000);
			return;
		}

		var startpos2 = tr.EndPosition;
		startpos2 += tr.Normal * -1;
		startpos2 += (Vector3.Up * 40);
		var endpos2 = startpos2;
		endpos2 += (Vector3.Up * -2);
		var trupdown = Trace.Ray(startpos2, endpos2).StaticOnly().Run();
		//DebugOverlay.Line(trupdown.StartPosition, trupdown.EndPosition, Color.Blue);
		if (!trupdown.Hit)
		{
			Stool.Position = new Vector3(0, 0, -100000);
			return;
		}


		Stool.Position = tr.EndPosition;

		var tr2 = Trace.Ray(Stool.Position, Stool.Position + (Vector3.Down * 128)).StaticOnly().Run();
		Stool.Position = tr2.EndPosition;
		Stool.Rotation = (tr.Normal * -1).EulerAngles.ToRotation().RotateAroundAxis(Vector3.Down, 90);
		 
	} 
}
