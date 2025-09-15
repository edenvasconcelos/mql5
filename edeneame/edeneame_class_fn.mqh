double calcularDistanciaPercentual(double percentual_perda, double volume, double saldo)
{
   if (volume <= 0){
      volume = 0.01;
   }
   double perda_maxima = saldo * (percentual_perda / 100.0);

   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   // Quantos ticks equivalem à perda máxima para o volume operado
   double ticks = perda_maxima / (tick_value * volume);

   // Distância em preço
   double distancia = NormalizeDouble(ticks * tick_size, _Digits);

   return distancia;
}

// Enum para tipos de candle
enum CandleType
{
   CANDLE_UNKNOWN = 0,
   CANDLE_DOJI,
   CANDLE_BULLISH,
   CANDLE_BEARISH,
   CANDLE_MORNING_STAR,
   CANDLE_EVENING_STAR
};


// Função para identificar o tipo de candle usando vetor rates (rates[0]=atual, rates[1]=anterior, rates[2]=anterior ao anterior)
CandleType identificarTipoCandle(MqlRates &rates[])
{
   const MqlRates candle = rates[1];
   const MqlRates prev1  = rates[2];
   const MqlRates prev2  = rates[3];

   double corpo = MathAbs(candle.close - candle.open);
   double pavio_superior = candle.high - MathMax(candle.close, candle.open);
   double pavio_inferior = MathMin(candle.close, candle.open) - candle.low;
   double tamanho_total = candle.high - candle.low;

   // Doji: corpo pequeno em relação ao tamanho total
   if(corpo <= tamanho_total * 0.1)
      return CANDLE_DOJI;

   // Bullish (alta): fechamento acima da abertura
//   if(candle.close > candle.open)
//      return CANDLE_BULLISH;

   // Bearish (baixa): fechamento abaixo da abertura
//   if(candle.close < candle.open)
//      return CANDLE_BEARISH;

   // Morning Star (padrão de reversão de baixa para alta)
   if(prev2.close < prev2.open && // candle 2: bearish
      prev1.close <= prev1.open && // candle 1: pequeno corpo (pode ser doji)
      candle.close > candle.open && // candle atual: bullish
      candle.close > prev2.open)
      return CANDLE_MORNING_STAR;

   // Evening Star (padrão de reversão de alta para baixa)
   if(prev2.close > prev2.open && // candle 2: bullish
      prev1.close >= prev1.open && // candle 1: pequeno corpo (pode ser doji)
      candle.close < candle.open && // candle atual: bearish
      candle.close < prev2.open)
      return CANDLE_EVENING_STAR;

   return CANDLE_UNKNOWN;
}

// Exemplo de uso:
// CandleType

// Função para verificar se é um novo dia
bool verificarNovoDia()
{
   static int ultimoDia = -1;

   datetime agora = TimeCurrent();
   MqlDateTime dataAtual;
   TimeToStruct(agora, dataAtual);

   if(dataAtual.day != ultimoDia)
   {
   //   Print("🌅 Novo dia detectado: ", TimeToString(agora, TIME_DATE));
      ultimoDia = dataAtual.day;
      return true;
      // Lógica personalizada para o início do dia
   }
   return false;
}

