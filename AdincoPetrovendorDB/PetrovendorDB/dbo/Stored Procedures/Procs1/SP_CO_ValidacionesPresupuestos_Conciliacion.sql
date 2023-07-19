CREATE PROCEDURE [dbo].[SP_CO_ValidacionesPresupuestos_Conciliacion]
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @EsHistorico BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE
               WHEN ISNULL(IdPresupuestoCNH, '') = ''
                    OR IdPresupuestoCNH = 'FALTA ID' THEN
                   'El presupuesto: [ ' + Nombre + ' ] con fecha fin vigencia '
                   + CONVERT(NVARCHAR(MAX), FinPresupuesto) + ' está fuera del periodo.'
               ELSE
                   'El presupuesto: [ ' + Nombre + ' - ' + SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH) - 8, 9)
                   + ' ] con fecha fin vigencia ' + CONVERT(NVARCHAR(MAX), FinPresupuesto) + ' está fuera del periodo.'
           END AS Validaciones
    FROM dbo.CO_Presupuesto
    WHERE FinPresupuesto IS NOT NULL
          AND IdPresupuesto = @IdPresupuesto
          AND @EsHistorico = 0
    UNION
    SELECT CASE
               WHEN ISNULL(IdPresupuestoCNH, '') = ''
                    OR IdPresupuestoCNH = 'FALTA ID' THEN
                   'El presupuesto: [ ' + Nombre + ' ] con fecha fin vigencia '
                   + CONVERT(NVARCHAR(MAX), FinPresupuesto) + ' está fuera de los últimos 6 meses permitidos.'
               ELSE
                   'El presupuesto: [ ' + Nombre + ' - ' + SUBSTRING(IdPresupuestoCNH, LEN(IdPresupuestoCNH) - 8, 9)
                   + ' ] con fecha fin vigencia ' + CONVERT(NVARCHAR(MAX), FinPresupuesto)
                   + ' está fuera de los últimos 6 meses permitidos.'
           END AS Validaciones
    FROM dbo.CO_Presupuesto
    WHERE FinPresupuesto IS NOT NULL
          AND IdPresupuesto = @IdPresupuesto
          AND @EsHistorico = 0;
END;