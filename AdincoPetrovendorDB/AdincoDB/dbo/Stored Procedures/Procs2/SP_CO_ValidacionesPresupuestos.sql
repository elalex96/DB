
-- =============================================
-- Author:      Marcos Garcia
-- Create date: 15-02-2020
-- Description: Validaciones del Presupuesto
-- =============================================
-- Author:      Manuel Cruz
-- Create date: 04-01-2023
-- Description: Ajuste en texto de mensaje y rango de fechas en el where
-- =============================================
-- Modificado:       Neri del Angel
-- Fecha Modificado: 11 de Enero del 2023
-- Description:      Se agregan las variables de @EsHistorico y @Mes
--					 @Mes reemplaza el getdate de la comparación de fechas para las validaciones
--					 @EsHistorico si es 1 omite las validaciones de presupuestos
--				     Se quita la opción del acción ya que ahora ya no limpiara el Excel solo informara si esta fuera de fecha fin
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ValidacionesPresupuestos]
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @Accion INT,
    @Mes DATE,
    @EsHistorico BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE
               WHEN IdPresupuestoCNH IS NULL
                    OR IdPresupuestoCNH = ''
                    OR IdPresupuestoCNH = 'FALTA ID' THEN
                   'El presupuesto: [ ' + Nombre + ' ] con fecha fin vigencia '
                   + CONVERT(NVARCHAR(MAX), FinPresupuesto) + ' está fuera del periodo.'
               ELSE
                   'El presupuesto: [ ' + Nombre + ' - ' + SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH) - 8, 9)
                   + ' ] con fecha fin vigencia ' + CONVERT(NVARCHAR(MAX), FinPresupuesto) + ' está fuera del periodo.'
           END AS Validaciones
    FROM dbo.CO_Presupuesto
    WHERE DATEDIFF(MONTH, FinPresupuesto, @Mes) >= 1
          AND DATEDIFF(MONTH, FinPresupuesto, @Mes) <= 6
          AND FinPresupuesto IS NOT NULL
          AND IdPresupuesto = @IdPresupuesto
          AND @EsHistorico = 0
    UNION
    SELECT CASE
               WHEN IdPresupuestoCNH IS NULL
                    OR IdPresupuestoCNH = ''
                    OR IdPresupuestoCNH = 'FALTA ID' THEN
                   'El presupuesto: [ ' + Nombre + ' ] con fecha fin vigencia '
                   + CONVERT(NVARCHAR(MAX), FinPresupuesto) + ' está fuera de los últimos 6 meses permitidos.'
               ELSE
                   'El presupuesto: [ ' + Nombre + ' - ' + SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH) - 8, 9)
                   + ' ] con fecha fin vigencia ' + CONVERT(NVARCHAR(MAX), FinPresupuesto)
                   + ' está fuera de los últimos 6 meses permitidos.'
           END AS Validaciones
    FROM dbo.CO_Presupuesto
    WHERE DATEDIFF(MONTH, FinPresupuesto, @Mes) >= 7
          AND FinPresupuesto IS NOT NULL
          AND IdPresupuesto = @IdPresupuesto
          AND @EsHistorico = 0;
END;