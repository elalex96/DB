-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2016
-- Description:	Consulta los Gastos Aceptados Mensuales
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaGastosAceptadosMensualCIEP] 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0 , 
	@IdIdioma int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set language spanish
    -- Insert statements for procedure here
SELECT      [IdGEAceptadoMes]
      ,[IdContrato]
      ,[GEAprobados] as Monto
      ,[Mes]
      ,[CreadoPor]
      ,[CreadoEl]
      ,[ModificadoPor]
      ,[ModificadoEl]
      ,[Activo]   Mes,  RIGHT('00'+CAST(month([Mes]) AS VARCHAR(2)),2) + ' ' +DATENAME (month,[Mes]) as NombreMes,  DATENAME (YEAR, [Mes]) as Anio
FROM            CO_GEAceptadosMes
WHERE        (IdContrato = @IdContrato)
END
