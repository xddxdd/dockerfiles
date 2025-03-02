FROM lmsysorg/sglang:latest

ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV MODEL_PATH=reinforce20001/SakuraLLM.Sakura-14B-Qwen2.5-v1.0-W8A8-Int8-V2

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh \
    && git clone https://github.com/xddxdd/Sakura_Launcher_GUI.git /sakura_share
ENTRYPOINT ["/entrypoint.sh"]
