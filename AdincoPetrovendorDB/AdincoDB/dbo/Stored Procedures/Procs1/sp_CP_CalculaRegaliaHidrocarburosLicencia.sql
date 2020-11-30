CREATE PROCEDURE [dbo].[sp_CP_CalculaRegaliaHidrocarburosLicencia] 
	@IdContrato       INT  = 0, 
	@Periodo          DATE, 
	@TipoHidrocarburo INT
AS
     BEGIN
         -- =============================================
         -- Author:		Miguel Gomez
         -- Create date: 2017-01-01
         -- Description:	Calcula valor de los hidrocarburos
         -- =============================================
         SET NOCOUNT ON
         IF @TipoHidrocarburo = 3
		 BEGIN 
             SELECT CO_TipoHidrocarburo.Hidrocarburo, 
                    ROUND(MCH.Precio, 2) AS [Precio], 
                    ISNULL(MCH.Volumen, 0) AS Volumen,
                    --ISNULL(MCH.Valor, 0) AS Valor,
                    ROUND(MCH.Precio, 2) * ISNULL(MCH.Volumen, 0) AS [Valor], 
                    ROUND(MCH.TasaRegalia, 2) AS [TasaRegalia], 
                    ROUND((MCH.TasaRegalia / 100) * (ROUND(MCH.Precio, 2) * ISNULL(MCH.Volumen, 0)), 2) AS Regalia, 
                    MCH.urlimgregalia
             FROM CP_MetodoCalculoHidrocarburoMes MCH
                  JOIN CO_TipoHidrocarburo ON MCH.IdTipoHidrocarburo = CO_TipoHidrocarburo.TipoHidrocarburo
             WHERE MCH.IdContrato = @IdContrato
                   AND MCH.Mes = @Periodo
                   AND CO_TipoHidrocarburo.TipoHidrocarburo IN(3, 4, 5, 6)
		END
        ELSE
		BEGIN
         SELECT CO_TipoHidrocarburo.Hidrocarburo,
                --MCH.Precio,
                ROUND(MCH.Precio, 2) AS [Precio], 
                ISNULL(MCH.Volumen, 0) AS Volumen,
                --ISNULL(MCH.Valor, 0) AS Valor,
                ROUND(MCH.Precio, 2) * ISNULL(MCH.Volumen, 0) AS [Valor], 
                ROUND(MCH.TasaRegalia, 2) AS [TasaRegalia], 
                ROUND((MCH.TasaRegalia / 100) * (ROUND(MCH.Precio, 2) * ISNULL(MCH.Volumen, 0)), 2) AS Regalia, 
                MCH.urlimgregalia
         FROM CP_MetodoCalculoHidrocarburoMes MCH
              JOIN CO_TipoHidrocarburo ON MCH.IdTipoHidrocarburo = CO_TipoHidrocarburo.TipoHidrocarburo
         WHERE MCH.IdContrato = @IdContrato
               AND MCH.Mes = @Periodo
               AND CO_TipoHidrocarburo.TipoHidrocarburo = @TipoHidrocarburo
     END
END

