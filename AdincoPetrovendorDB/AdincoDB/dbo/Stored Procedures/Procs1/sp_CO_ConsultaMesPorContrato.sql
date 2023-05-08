creATE procedure [dbo].[sp_CO_ConsultaMesPorContrato]
@IdContrato int 
as
--===================================================================
--Created at: 2018/06/22
--Created by: Luisdaviddela
--===================================================================
begin

 DECLARE @Anio NVARCHAR(10);
         SELECT @Anio = InicioVigencia
         FROM CO_Contrato
         WHERE IdContrato = @IdContrato;
		 --=======================================================================
		 SELECT
		 distinct
         Month(IdFecha) AS Mes,
		 NombreMes
         FROM AP_Calendario C
         WHERE C.Dia = 1
               AND YEAR(C.IdFecha) 
			   BETWEEN YEAR(@Anio) 
			   AND YEAR(CURRENT_TIMESTAMP)
         GROUP BY 
		 Month(C.IdFecha),
		 NombreMes
         ORDER BY 
		 Month(C.IdFecha)
		 DESC;
     --=======================================================================

end
