module MapElements.TriggerManager;

import GBAUtils.DataStore;
import GBAUtils.GBARom;
import GBAUtils.ISaveable;
import MapElements.Trigger;
import IO.Map;

public class TriggerManager : ISaveable
{
	public Trigger[] mapTriggers;
	private Map loadedMap;
	private int internalOffset = 0;
	private int originalSize;
	private GBARom rom;


	public this(GBARom rom, Map m, int count)
	{
		LoadTriggers(rom, m, count);

	}

	public this(GBARom rom, Map m, int offset, int count)
	{
		rom.Seek(offset);
		LoadTriggers(rom, m, count);
	}

	public void LoadTriggers(GBARom rom, Map m, int count)
	{
		internalOffset = rom.internalOffset;
		mapTriggers.length = 1;
		int i = 0;
		for (i = 0; i < count; i++)
		{
			mapTriggers[i] = new Trigger(rom);
			mapTriggers.length++;
		}
		originalSize = getSize();
		this.rom = rom;
		this.loadedMap = m;
	}

	public int getSpriteIndexAt(ubyte x, ubyte y)
	{
		int i = 0;
		for (i = 0; i < mapTriggers.length; i++)
		{
			if (mapTriggers[i].bX == x && mapTriggers[i].bY == y)
			{
				return i;
			}
		}

		return -1;
	}
	
	public int getSize()
	{
		return cast(uint)mapTriggers.length * Trigger.getSize();
	}

	public void add(ubyte x, ubyte y)
	{
		mapTriggers ~= new Trigger(rom, x, y);
	}

	public void remove(ubyte x, ubyte y)
	{
	    std.algorithm.remove(mapTriggers, getSpriteIndexAt(x,y));
	}

	public void save()
	{
		rom.floodBytes(internalOffset, rom.freeSpaceByte, originalSize);

		// TODO make this a setting, ie always repoint vs keep pointers
		int i = getSize();
		if (originalSize < getSize())
		{
			internalOffset = rom.findFreespace(DataStore.FreespaceStart, getSize());

			if (internalOffset < 0x08000000)
				internalOffset += 0x08000000;
		}

		loadedMap.mapSprites.pTraps = internalOffset & 0x1FFFFFF;
		loadedMap.mapSprites.bNumTraps = cast(ubyte) mapTriggers.length;

		rom.Seek(internalOffset);
		foreach(Trigger t; mapTriggers)
			t.save();
	}
}
