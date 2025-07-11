double calcularDistanciaPercentual(double percentual_perda, double volume, double saldo)
{
   double perda_maxima = saldo * (percentual_perda / 100.0);

   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   // Quantos ticks equivalem à perda máxima para o volume operado
   double ticks = perda_maxima / (tick_value * volume);

   // Distância em preço
   double distancia = NormalizeDouble(ticks * tick_size, _Digits);

   return distancia;
}


