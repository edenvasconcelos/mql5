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
