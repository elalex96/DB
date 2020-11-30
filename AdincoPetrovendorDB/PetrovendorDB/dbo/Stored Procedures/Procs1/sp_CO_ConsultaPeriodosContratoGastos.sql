CREATE PROCEDURE [dbo].[sp_CO_ConsultaPeriodosContratoGastos] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int = 0
AS
BEGIN
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 4-01-2017
-- Description:	Consulta los periodos de un contrato
-- =============================================
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT        IdPeriodo,  NombrePeriodo  as NombreParaMostrar
    FROM            CO_PeriodoContrato
    WHERE        (IdProveedor = @IdProveedor)
    and CO_PeriodoContrato.activo= 1
    ORDER BY inicio
END

