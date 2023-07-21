using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Sandbox;
using TerrorTown;

namespace MinecraftExperience;

public class MainShit
{
	[Event("Player.PostSpawn")]
	public static void PostPlayerSpawn(TerrorTown.Player player)
	{
		double gravity = 0.20000000298023224;
		gravity *= 40; // mc block size in units 
		gravity /= (1f/64f); // our tickrate
		gravity *= 2; // gravity is halved in walk controller

		float jump = 0.42f;
		jump *= 40; // mc block size in units 
		jump /= (1f / 20f); // minecrafts tickrate

		double walk = 0.10000000149011612;
		walk *= 40; // mc block size in units 
		walk /= (1f / 20f); // minecrafts tickrate
		walk *= 2; // ?????

		float slipperiness = 0.6f; //0.91?;
		float friction = 0.91f;
		friction *= 0.91f;
		//friction /= (1f / 20f);
							//float friction = 0.16277136F / (f * f * f);

		TerrorTown.WalkController.Gravity = (float)gravity;
		TerrorTown.WalkController.JumpForce = jump;
		TerrorTown.WalkController.StepSize = 20;
		TerrorTown.WalkController.WalkSpeed = (float)walk;
		TerrorTown.WalkController.DefaultSpeed = (float)walk * 1.3f;
		TerrorTown.WalkController.SprintSpeed = (float)walk *1.3f;
		TerrorTown.WalkController.ForceSimpleFriction = true;
		TerrorTown.WalkController.SimpleFriction = friction;
		Log.Info("MC init");
		player.Components.Add(new SmoothStepComponent());
	} 

	static float prevlength;
	static float length;

	static float prevYaw;
	static float prevPitch;

	[GameEvent.Client.PostCamera]
	static void PostCamera()
	{

		var ply = Game.LocalPawn as TerrorTown.Player;
		var WishVelocity = new Vector3(ply.InputDirection.x.Clamp(-1f, 1f), ply.InputDirection.y.Clamp(-1f, 1f), 0);
		WishVelocity *= ply.ViewAngles.WithPitch(0).ToRotation();
		WishVelocity = (ply.Velocity/64)/2;	
		length += ((MathF.Sqrt(WishVelocity.x * WishVelocity.x + WishVelocity.y * WishVelocity.y) * 0.6f) * 4) * Time.Delta;


		float f = (length - prevlength);//entityplayer.distanceWalkedModified - entityplayer.prevDistanceWalkedModified;
		var b = 1;
		float f1 = -(length + f * b);
		float f2 = 1f;// prevYaw + (Camera.Rotation.Angles().yaw - prevYaw) * b;
		float f3 = 1f;// prevPitch + (ply.ViewAngles.pitch - prevPitch) * b;


		//GlStateManager.translate(MathHelper.sin(f1 * (float)Math.PI) * f2 * 0.5F, -Math.abs(MathHelper.cos(f1 * (float)Math.PI) * f2), 0.0F);
		//GlStateManager.rotate(MathHelper.sin(f1 * (float)Math.PI) * f2 * 3.0F, 0.0F, 0.0F, 1.0F);
		//GlStateManager.rotate(Math.abs(MathHelper.cos(f1 * (float)Math.PI - 0.2F) * f2) * 5.0F, 1.0F, 0.0F, 0.0F);
		//GlStateManager.rotate(f3, 1.0F, 0.0F, 0.0F);
		
		var mult = (1f/64f)*2;
		Camera.Position += (new Vector3(MathF.Sin(f1 * MathF.PI) * f2 * 0.5F, 0.0f, -MathF.Abs(MathF.Cos(f1 * MathF.PI) * f2)) * 20) * mult;
		var roll = (MathF.Sin(f1 * MathF.PI) * f2 * 3.0F) * mult;
		var pitch1 = (MathF.Abs(MathF.Cos(f1 * MathF.PI - 0.2F) * f2) * 5.0f) * mult;
		var pitch2 = f3 * mult;
		Camera.Rotation = Camera.Rotation.RotateAroundAxis(Vector3.Forward, roll); //Maybe Vector3.Left?
		Camera.Rotation = Camera.Rotation.RotateAroundAxis(Vector3.Left, pitch1); //Maybe Vector3.Forward?
		Camera.Rotation = Camera.Rotation.RotateAroundAxis(Vector3.Left, pitch2); //Maybe Vector3.Forward?


		//Camera.Rotation = Camera.Rotation.RotateAroundAxis(Vector3.Up, FakeCamRotation.Yaw());
		//Camera.Rotation = ply.ViewAngles.WithPitch(FakeCamRotation.Pitch()).ToRotation();
		//Camera.Rotation = ply.ViewAngles.WithYaw(FakeCamRotation.Yaw()).ToRotation();
		//Log.Info(roll);
		prevlength = length;
		prevPitch = Camera.Rotation.Angles().pitch;
		prevYaw = Camera.Rotation.Angles().yaw;// (ply.ViewAngles.yaw + 90) / 360;
	}
}
