using Godot;
using System;

// Если VoxelGeneratorScript не найден, попробуйте наследоваться от RefCounted.
// Godot увидит методы по именам (_GenerateBlock), если плагин это поддерживает.
[GlobalClass]
public partial class SkyBlockGenerator : RefCounted 
{
	[Export]
	public Variant BlockLib { get; set; }

	[Export]
	public int GridStep { get; set; } = 4;

	private const int ChannelType = 0;

	// Этот метод вызывается движком через Reflection
	public int _GetUsedChannelsMask()
	{
		return 1 << ChannelType;
	}

	// Этот метод вызывается движком через Reflection
	public void _GenerateBlock(Variant bufferVariant, Vector3I origin, int lod)
	{
		if (lod != 0) return;

		GodotObject buffer = bufferVariant.As<GodotObject>();
		if (buffer == null || BlockLib.As<GodotObject>() == null) return;

		GodotObject lib = BlockLib.As<GodotObject>();
		int modelsCount = (int)lib.Call("get_model_count");
		if (modelsCount == 0) return;

		Vector3I size = (Vector3I)buffer.Call("get_size");

		for (int z = 0; z < size.Z; z++)
		{
			if ((origin.Z + z) % GridStep != 0) continue;
			for (int x = 0; x < size.X; x++)
			{
				if ((origin.X + x) % GridStep != 0) continue;
				for (int y = 0; y < size.Y; y++)
				{
					if ((origin.Y + y) % GridStep != 0) continue;

					Vector3I pos = new Vector3I(origin.X + x, origin.Y + y, origin.Z + z);
					// Убедитесь, что GlobalValues.WorldSeed доступен из C#
					uint posHash = GD.Hash(pos + new Vector3I(GlobalValues.WorldSeed, 0, 0));

					int randomBlockId = (int)(posHash % (uint)modelsCount) + 1;
					buffer.Call("set_voxel", randomBlockId, x, y, z, ChannelType);
				}
			}
		}
	}
}
