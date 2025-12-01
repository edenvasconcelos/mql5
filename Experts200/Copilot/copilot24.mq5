Despesas 2024.xlsx
//+------------------------------------------------------------------+
//|                                                copilot16.mql.mq5 |
//|                                 Copyright 2023, Eden Vasconcelos |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Eden Vasconcelos"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
void Comprar(double stopLoss, double takeProfit)
{
    // Definir os parâmetros da ordem de compra
    double lote = 0.1; // Defina o tamanho do lote conforme sua gestão de risco

    // Obter o preço de compra
    double precoCompra = SymbolInfoDouble(Symbol(), SYMBOL_ASK);

    // Colocar a ordem de compra
    int ticket = OrderSend(Symbol(), OP_BUY, lote, precoCompra, 3, precoCompra - stopLoss, precoCompra + takeProfit, "Compra", 0, 0, clrGreen);
    if (ticket < 0)
    {
        Print("Erro ao abrir ordem de compra: ", GetLastError());
    }
    else
    {
        Print("Ordem de compra aberta com sucesso: ", ticket);
    }
}

void Vender(double stopLoss, double takeProfit)
{
    // Definir os parâmetros da ordem de venda
    double lote = 0.1; // Defina o tamanho do lote conforme sua gestão de risco

    // Obter o preço de venda
    double precoVenda = SymbolInfoDouble(Symbol(), SYMBOL_BID);

    // Colocar a ordem de venda
    int ticket = OrderSend(Symbol(), OP_SELL, lote, precoVenda, 3, precoVenda + stopLoss, precoVenda - takeProfit, "Venda", 0, 0, clrRed);
    if (ticket < 0)
    {
        Print("Erro ao abrir ordem de venda: ", GetLastError());
    }
    else
    {
        Print("Ordem de venda aberta com sucesso: ", ticket);
    }
}
void estrategia16(MqlRates &_rates[], int p_tempo_grafico)
{
    // Definir as cores
    color emaColor = clrRed;
    color smaColor = clrYellow;

    int handleEma = iMA(Symbol(), p_tempo_grafico, 50, 0, MODE_EMA, PRICE_CLOSE);
    int handleSma = iMA(Symbol(), p_tempo_grafico, 100, 0, MODE_SMA, PRICE_CLOSE);
    int handleAtr = iATR(Symbol(), p_tempo_grafico, 14);
    int handleRsi = iRSI(Symbol(), p_tempo_grafico, 14, PRICE_CLOSE);

    int bufferSize = 15; // Tamanho do buffer para calcular a tendência
    double emaBuffer[2];
    double smaBuffer[bufferSize];
    double atrBuffer[14];
    double rsiBuffer[2];
    
    // Configurar os arrays como séries temporais
    ArraySetAsSeries(emaBuffer, true);
    ArraySetAsSeries(smaBuffer, true);
    ArraySetAsSeries(atrBuffer, true);
    ArraySetAsSeries(rsiBuffer, true);

    // Obter os valores anteriores e atuais da EMA e SMA
    if (CopyBuffer(handleEma, 0, 0, 2, emaBuffer) != 2)
    {
        Comment("Erro ao copiar os valores da EMA");
        return;
    }
    if (CopyBuffer(handleSma, 0, 0, bufferSize, smaBuffer) != bufferSize)
    {
        Comment("Erro ao copiar os valores da SMA");
        return;
    }
    if (CopyBuffer(handleRsi, 0, 0, 2, rsiBuffer) != 2)
    {
        Comment("Erro ao copiar os valores do RSI");
        return;
    }

    double emaPrev = emaBuffer[1];
    double emaCurrent = emaBuffer[0];
    double rsiCurrent = rsiBuffer[0];

    // Calcular a tendência do mercado para todos os valores do buffer
    TendenciaResultado resultadoTendencia = calcularTendencia(smaBuffer, bufferSize);

    // Verificar se a tendência é forte o suficiente (maior que 60%)
    if (resultadoTendencia.percentual <= 60)
    {
        Comment("Tendência fraca: ", resultadoTendencia.tipo, " (", resultadoTendencia.percentual, "%)");
        return;
    }

    // Obter os valores dos últimos 14 períodos do ATR
    if (CopyBuffer(handleAtr, 0, 0, 14, atrBuffer) != 14)
    {
        Comment("Erro ao copiar os valores do ATR");
        return;
    }
    
    // Obter o valor atual do ATR
    double atrCurrent = atrBuffer[0];
    
    // Calcular o valor máximo do ATR nos últimos 14 períodos
    double atrMax = ArrayMaximum(atrBuffer);
    
    // Verificar se atrMax não é zero antes de calcular o ATR em percentual
    double atrPercentualMax = 0;
    if (atrMax != 0)
    {
        atrPercentualMax = (atrCurrent / atrMax) * 100;
    }

    // Gerar IDs únicos para os objetos
    string emaID = "EMA_Line_" + IntegerToString(TimeLocal());
    string smaID = "SMA_Line_" + IntegerToString(TimeLocal());

    // Desenhar a EMA com a cor vermelha
    ObjectCreate(0, emaID, OBJ_TREND, 0, _rates[1].time, emaPrev, _rates[0].time, emaCurrent);
    ObjectSetInteger(0, emaID, OBJPROP_COLOR, emaColor);
    ObjectSetInteger(0, emaID, OBJPROP_WIDTH, 2);

    // Adicionar o ID ao array dinâmico
    ArrayResize(emaIDs, ArraySize(emaIDs) + 1);
    emaIDs[ArraySize(emaIDs) - 1] = emaID;

    // Desenhar a SMA com a cor amarela
    ObjectCreate(0, smaID, OBJ_TREND, 0, _rates[1].time, smaPrev, _rates[0].time, smaCurrent);
    ObjectSetInteger(0, smaID, OBJPROP_COLOR, smaColor);
    ObjectSetInteger(0, smaID, OBJPROP_WIDTH, 2);

    // Adicionar o ID ao array dinâmico
    ArrayResize(smaIDs, ArraySize(smaIDs) + 1);
    smaIDs[ArraySize(smaIDs) - 1] = smaID;

    // Remover objetos mais antigos se o tamanho do array for maior que 14
    if (ArraySize(emaIDs) > 14)
    {
        ObjectDelete(0, emaIDs[0]);
        ArrayRemove(emaIDs, 0, 1);
    }
    if (ArraySize(smaIDs) > 14)
    {
        ObjectDelete(0, smaIDs[0]);
        ArrayRemove(smaIDs, 0, 1);
    }

    // Calcular os níveis de stop loss e take profit
    double stopLoss = atrCurrent * 1.5;
    double takeProfit = atrCurrent * 2.0;

    // Verificar cruzamentos, tendência, RSI e executar a operação
    if(emaPrev < smaPrev && emaCurrent > smaCurrent && rsiCurrent > 50 && resultadoTendencia.tipo == "Compra")
    {
        Comprar(stopLoss, takeProfit);
        Comment("Cruzamento para cima: EMA cruzou acima da SMA\n",
                "RSI: ", rsiCurrent, " (Confirmação de Compra)\n",
                "Tendência: ", resultadoTendencia.tipo, "\n",
                "Percentual da Tendência: ", DoubleToString(resultadoTendencia.percentual, 2), "%\n",
                "ATR atual: ", atrCurrent, "\n",
                "ATR atual em percentual em relação ao ATR máximo: ", 
                atrPercentualMax, "%\n",
                "Stop Loss: ", stopLoss, "\n",
                "Take Profit: ", takeProfit);
    }
    else if(emaPrev > smaPrev && emaCurrent < smaCurrent && rsiCurrent < 50 && resultadoTendencia.tipo == "Venda")
    {
        Vender(stopLoss, takeProfit);
        Comment("Cruzamento para baixo: EMA cruzou abaixo da SMA\n",
                "RSI: ", rsiCurrent, " (Confirmação de Venda)\n",
                "Tendência: ", resultadoTendencia.tipo, "\n",
                "Percentual da Tendência: ", DoubleToString(resultadoTendencia.percentual, 2), "%\n",
                "ATR atual: ", atrCurrent, "\n",
                "ATR atual em percentual em relação ao ATR máximo: ", 
                atrPercentualMax, "%\n",
                "Stop Loss: ", stopLoss, "\n",
                "Take Profit: ", takeProfit);
    }
}