-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EP_AgregarEvaluacionProveedor]
@IdProveedorEvaluado          INT,
@IdEvaluador                  INT,
@IdEvaluacionProveedorDetalle INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TotalDePuntos int 
	SET @TotalDePuntos = (
						SELECT SUM(PCE.valor * EPD.Ponderacion) AS TotalPuntos 
						FROM EP_EvaluacionProveedorDetalle EPD
						INNER JOIN EP_PregConceptoEvaluar PCE
						ON EPD.IdConceptoEvaluar = PCE.IdConceptoEvaluar
						WHERE IdPedidoReferencia = @IdEvaluacionProveedorDetalle
						)
  
    INSERT INTO EP_EvaluacionProveedor(
	IdProveedorEvaluado,
	IdEvaluacionProveedorDetalle,
	FechaRegistro,
	IsActivo,
	TotalDePuntos,
	Evaluador
	)
	VALUES(
	@IdProveedorEvaluado,
	@IdEvaluacionProveedorDetalle,
	GETDATE(),
	1,
	@TotalDePuntos,
	@IdEvaluador   
	)

	SELECT @@IDENTITY

END

