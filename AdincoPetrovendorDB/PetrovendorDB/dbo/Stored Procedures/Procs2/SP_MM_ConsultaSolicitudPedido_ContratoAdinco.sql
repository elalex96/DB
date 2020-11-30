-- =============================================
-- Author:		Daniel AC
-- Create date: 08-08-17
-- Description: 
-- Actualice referencia a Adinco antes era Adinco_Desarrollo
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedido_ContratoAdinco]
	-- Add the parameters for the stored procedure here
	@IdContrato int, 
	@IdPeriodo int,
	@IdPresupuesto int,
	@IdLineaPresupuesto int
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	---ADINCO_DESARROLLO.dbo.PV_Subcontratista ADINCO
	DECLARE @CONTRATO NVARCHAR(max)
	DECLARE @PRESUPUESTO NVARCHAR(max)
	DECLARE @PERIODO NVARCHAR(max)
	DECLARE @LINEAPRESUPUESTO NVARCHAR(max)

   EXECUTE [Adinco].[dbo].[SP_PV_MM_ConsultaDetalleAdinco_SolicitudPedido] @IdContrato,@IdPeriodo,@IdPresupuesto,@IdLineaPresupuesto

	 
END



