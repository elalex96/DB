USE Adinco;
GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ConsultaAñosPorContrato'

    )
    DROP PROCEDURE USP_SEL_CO_ConsultaAñosPorContrato
GO
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26-01-2024
-- Description:	Consulta lista de meses por contrato
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_CO_ConsultaAñosPorContrato] --10,10007
    @UsuarioId   INT,
    @ContratoId   INT
AS
     BEGIN

         SET NOCOUNT ON;

         SET LANGUAGE spanish;
         DECLARE @FechaEfectiva AS DATE;


         SELECT @FechaEfectiva = InicioVigencia
         FROM CO_Contrato (NOLOCK)
         WHERE IdContrato = @ContratoId;


         IF @ContratoId = 10007
             BEGIN
                 SELECT 	
						CAST(AP_Calendario.IdFecha AS DATE) AS IdFecha, 
                         YEAR(IdFecha) AS Fecha
                 FROM AP_Calendario (NOLOCK)
                 WHERE AP_Calendario.Dia = 1  AND AP_Calendario.Mes = 1
                       AND AP_Calendario.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
                 ORDER BY AP_Calendario.IdFecha DESC;
             END;

             ELSE
             BEGIN
                 SELECT  
						CAST(AP_Calendario.IdFecha AS DATE) AS IdFecha, 
                        YEAR(IdFecha) AS Fecha
                 FROM AP_Calendario (NOLOCK)
                 WHERE AP_Calendario.Dia = 1 AND AP_Calendario.Mes = 1
                       AND AP_Calendario.IdFecha BETWEEN DATEADD(month, -1, @FechaEfectiva) AND CURRENT_TIMESTAMP
                 ORDER BY AP_Calendario.IdFecha DESC;
             END;

     END;
