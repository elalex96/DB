-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PCN_AgregarValores]

@IdPedidoDetalle int,
@VNMO_SueldoNacional decimal,
@VMO_Sueldo decimal,
@CreadoPor int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[MM_PCN_ValoresPesos](
	[IdAceptacionPedidoDetalle],
	[VNMO_SueldoNacional],
	[VMO_Sueldo],
	[CreadoPor],
	[CreadoEl]
	)
	VALUES(
	@IdPedidoDetalle,
	@VNMO_SueldoNacional,
	@VMO_Sueldo,
	@CreadoPor,
	GETDATE()
	)

	SELECT @@IDENTITY  AS IdValoresEnPesosPedidoDetalle
END

