struct InformacaoGeral {
   long numero_magico;
   double preco_abertura;
   double maxima_dia;
   double minima_dia;
   double minima_semana;
   double maxima_semana;
   double minima_mes;
   double maxima_mes;
   double preco;
   bool newBar;
   bool newDay;
   
   double lot;
   double fator_tp;
   double fator_sl;
   double stop_move;
   
   double profit_dia;
   double profit_semana;
   double profit_mes;
   
   double buy_force;
   double sell_force;
   
};

struct InformacaoRisco {
   double valor_base_referencia;
   double perda_dia;
   double perda_semana;
   double perda_mes;
   double ganho_dia;
   double ganho_semana;
   double ganho_mes;
};
