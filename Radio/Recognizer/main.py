import asyncio
import Recognizing.RecognizeMaster

if __name__ == "__main__":
    recognize_master = Recognizing.RecognizeMaster.RecognizeMaster()
    asyncio.run(recognize_master.run())
