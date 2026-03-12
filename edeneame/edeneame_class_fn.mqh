
//+------------------------------------------------------------------+
//| Função que retorna o percentual da distância                     |
//| entre dois valores em relação a um valor de referência           |
//+------------------------------------------------------------------+
double calcularPercentualDistancia(double valor1, double valor2, double referencia)
{
   // Calcula a distância absoluta entre os dois valores
   double distancia = MathAbs(valor1 - valor2);
   
   // Evita divisão por zero
   if(referencia == 0.0)
      return 0.0;
   
   // Calcula o percentual da distância em relação ao valor de referência
   double percentual = ((referencia-valor1) / distancia ) * 100.0;
   
   return percentual;
}



//+------------------------------------------------------------------+
//| Função para calcular distância em pontos e ticks                 |
//+------------------------------------------------------------------+
int calcularDistanciaInPoints(double preco1, double preco2)
{
   // Obtém informações do ativo atual
   double point     = SymbolInfoDouble(_Symbol, SYMBOL_POINT);        // tamanho de 1 ponto
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE); // tamanho de 1 tick
   
   // Diferença absoluta entre os preços
   double diferenca = MathAbs(preco1 - preco2);
   
   // Distância em pontos
   int distancia = (int)MathRound(diferenca / point);
   
   // Distância em ticks
   int distanciaEmTicks = (int)MathRound(diferenca / tick_size);
   
   return distancia;
}

double calcularDistanciaPercentual(double percentual, double volume, double saldo)
{
   if (volume <= 0){
      volume = 0.01;
   }
   double valor_maxima = saldo * (percentual / 100.0);

   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   // Quantos ticks equivalem à valor máximo para o volume operado
   double ticks = valor_maxima / (tick_value * volume);

   // Distância em preço
   double distancia = NormalizeDouble(ticks * tick_size, _Digits);

   return distancia;
}


double calcularNovoVolume(double percentual, double saldo, double loss_acumulado, double distancia)
{
   // Valor máximo permitido (em dinheiro)
   double valor_maxima = saldo * (percentual / 100.0);

   // Ajusta considerando o loss acumulado
   double valor_restante = valor_maxima + loss_acumulado;
   if (valor_restante <= 0){
      return 0.01; // volume mínimo, já que não há margem para risco
   }

   // Informações do ativo
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   // Quantos ticks correspondem à distância desejada
   double ticks = distancia / tick_size;

   // Volume necessário para que valor_restante corresponda a essa distância
   double volume = NormalizeDouble(valor_restante / (tick_value * ticks), 2);

   // Ajusta para os limites e step do ativo
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double min_lot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   volume = MathMax(min_lot, MathMin(max_lot, MathFloor(volume / lot_step) * lot_step));

   return volume;
}


// Enum para tipos de candle
enum CandleType
{
   CANDLE_UNKNOWN = 0,
   CANDLE_DOJI,
   CANDLE_BULLISH,
   CANDLE_BEARISH,
   CANDLE_MORNING_STAR,
   CANDLE_EVENING_STAR,
   CANDLE_VENDA,
   CANDLE_COMPRA
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
   if(corpo <= tamanho_total * 0.5)
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

//+------------------------------------------------------------------+
//| Perceptron function                                              |
//+------------------------------------------------------------------+
double Perceptron(double &input_a[], double &weights[],  int input_size)
  {

// Calculate the sum
  // if (checkParam() ) return 1;
   
   double sum = 0;
   for(int i = 0; i < input_size; i++)
     {
     // Print("input_"+IntegerToString(i)+":"+DoubleToString(input_a[i]));
      sum += input_a[i] * weights[i];
     }

   double output = sum;

   return(output);
  }

//+------------------------------------------------------------------+
//| Calcula o valor do candle                                        |
//| Parâmetro: MqlRates e valor do lot                               |
//| Retorno: (distância em ticks) * tick_value * lot                 |
//+------------------------------------------------------------------+
double calcularValorCandle(MqlRates &rate, double lot)
  {
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);

   // Diferença de preço em pontos
   double diferencaPoints = MathAbs(rate.open - rate.close) / _Point;

   // Valor do candle em dinheiro
   double valorCandle = diferencaPoints * tick_value * lot;

   return valorCandle;
  }

 