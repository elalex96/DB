-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19/04/2020>
-- Description:	<Guardado individual del conceptos cn de compra direcya>
-- =============================================
CREATE PROCEDURE [dbo].[SP_OCD_GuardadoIndividualConceptoCN]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdProveedor INT,
	@IdFactura INT,
	@IdPedido INT,
	@DescripcionBienesServicios NVARCHAR(MAX),
	@ValorFactura FLOAT,
	@PCN FLOAT,
	@IdActividadBS INT,
	@ClasificacionSH INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @IdActividadBS = 0
	BEGIN
	    SET @IdActividadBS = NULL;
	END

	INSERT INTO dbo.CN_CompraDirecta
	(
	    IdContrato,
	    IdProveedor,
	    IdFactura,
	    IdPedido,
	    DescripcionBienesServicios,
	    ValorFactura,
	    PCN,
	    IdActividadBS,
	    ClasificacionSH,
	    Activo,
	    CreadoPor,
	    CreadoEl
	)
	VALUES
	(   @IdContrato,         -- IdContrato - int
	    @IdProveedor,         -- IdProveedor - int
	    @IdFactura,         -- IdFactura - int
	    @IdPedido,         -- IdPedido - int
	    @DescripcionBienesServicios,       -- DescripcionBienesServicios - nvarchar(max)
		@ValorFactura,       -- ValorFactura - float
	    @PCN,       -- PCN - float
	    @IdActividadBS,         -- IdActividadBS - int
	    @ClasificacionSH,         -- ClasificacionSH - int
	    1,      -- Activo - bit
	    @IdUsuario,         -- CreadoPor - int
	    GETDATE()  -- CreadoEl - datetime
	    );

	SELECT SCOPE_IDENTITY()
END
