#region Copyright & License Information
/*
 * Copyright 2007-2011 The OpenRA Developers (see AUTHORS)
 * This file is part of OpenRA, which is free software. It is made 
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation. For more information,
 * see COPYING.
 */
#endregion

using System;
using System.Linq;

namespace OpenRA.Traits
{
	public class PlayerResourcesInfo : ITraitInfo
	{
		public readonly int InitialCash = 10000;
		public readonly int InitialOre = 0;
		public readonly int AdviceInterval = 250;

		public object Create(ActorInitializer init) { return new PlayerResources(init.self, this); }
	}
	
	public class DebugResourceCashInfo : ITraitInfo
	{
		public object Create(ActorInitializer init) { return new DebugResourceCash(init.self); }
	}
	public class DebugResourceCash : ISync
	{
		readonly Actor self;
		public DebugResourceCash(Actor self){this.self = self;}
		[Sync] public int foo { get { return self.Trait<PlayerResources>().Cash; } }
	}
	
	public class DebugResourceOreInfo : ITraitInfo
	{
		public object Create(ActorInitializer init) { return new DebugResourceOre(init.self); }
	}
	public class DebugResourceOre : ISync
	{
		readonly Actor self;
		public DebugResourceOre(Actor self){this.self = self;}
		[Sync] public int foo { get { return self.Trait<PlayerResources>().Ore; } }
	}
	
	public class DebugResourceOreCapacityInfo : ITraitInfo
	{
		public object Create(ActorInitializer init) { return new DebugResourceOreCapacity(init.self); }
	}
	public class DebugResourceOreCapacity : ISync
	{
		readonly Actor self;
		public DebugResourceOreCapacity(Actor self){this.self = self;}
		[Sync] public int foo { get { return self.Trait<PlayerResources>().OreCapacity; } }
	}
	
	public class PlayerResources : ITick, ISync
	{
		readonly Player Owner;
		int AdviceInterval;

		public PlayerResources(Actor self, PlayerResourcesInfo info)
		{
			Owner = self.Owner;

			Cash = info.InitialCash;
			Ore = info.InitialOre;
			AdviceInterval = info.AdviceInterval;
		}

		[Sync]
		public int Cash;
		
		[Sync]
		public int Ore;
		[Sync]
		public int OreCapacity;

		public int DisplayCash;
		public int DisplayOre;

		public bool CanGiveOre(int amount)
		{
			return Ore + amount <= OreCapacity;
		}

		public void GiveOre(int num)
		{
			Ore += num;
			
			if (Ore > OreCapacity)
			{
				nextSiloAdviceTime = 0;
				Ore = OreCapacity;
			}
		}
		
		public bool TakeOre(int num)
		{
			if (Ore < num) return false;
			Ore -= num;
			
			return true;
		}
		
		public void GiveCash(int num)
		{
			Cash += num;
		}
		
		public bool TakeCash(int num)
		{			
			if (Cash + Ore < num) return false;
			
			// Spend ore before cash
			Ore -= num;
			if (Ore < 0)
			{
				Cash += Ore;
				Ore = 0;	
			}
			
			return true;
		}

		const float displayCashFracPerFrame = .07f;
		const int displayCashDeltaPerFrame = 37;
		int nextSiloAdviceTime = 0;

		public void Tick(Actor self)
		{
			var eva = self.World.WorldActor.Info.Traits.Get<EvaAlertsInfo>();

			OreCapacity = self.World.ActorsWithTrait<IStoreOre>()
                .Where(a => a.Actor.Owner == Owner)
				.Sum(a => a.Trait.Capacity);
			
			if (Ore > OreCapacity)
				Ore = OreCapacity;
			
			if (--nextSiloAdviceTime <= 0)
			{
				if (Ore > 0.8*OreCapacity)
					Owner.GiveAdvice(eva.SilosNeeded);
				
				nextSiloAdviceTime = AdviceInterval;
			}
			
			var diff = Math.Abs(Cash - DisplayCash);
			var move = Math.Min(Math.Max((int)(diff * displayCashFracPerFrame),
					displayCashDeltaPerFrame), diff);

			
			if (DisplayCash < Cash)
			{
				DisplayCash += move;
				Sound.PlayToPlayer(self.Owner, eva.CashTickUp);
			}
			else if (DisplayCash > Cash)
			{
				DisplayCash -= move;
				Sound.PlayToPlayer(self.Owner, eva.CashTickDown);
			}
			
			diff = Math.Abs(Ore - DisplayOre);
			move = Math.Min(Math.Max((int)(diff * displayCashFracPerFrame),
					displayCashDeltaPerFrame), diff);

			if (DisplayOre < Ore)
			{
				DisplayOre += move;
				Sound.PlayToPlayer(self.Owner, eva.CashTickUp);
			}
			else if (DisplayOre > Ore)
			{
				DisplayOre -= move;
				Sound.PlayToPlayer(self.Owner, eva.CashTickDown);
			}
		}
	}
}
