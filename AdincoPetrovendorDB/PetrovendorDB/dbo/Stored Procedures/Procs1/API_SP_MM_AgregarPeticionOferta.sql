-- =============================================
-- Author:	DANIEL AC
-- Create date: 08/03/2018
-- Description:	Agregar nueva petición oferta 
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 03/07/2019
-- Description:	se agrego la variable y guardado de la restriccion de cotizacion
-- =============================================
create PROCEDURE [dbo].[API_SP_MM_AgregarPeticionOferta]
    @IdSolicitudPedido INT,
    @IdProveedor INT,
    @IdUsuario INT,
    @IdTipoProceso INT,
    @JustificacionAdjDirecta NVARCHAR(MAX),
    @DocAdjDirecta NVARCHAR(MAX),
	@CotizacionRestringida BIT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    IF (@JustificacionAdjDirecta = '')
        SET @JustificacionAdjDirecta = NULL;
    IF (@DocAdjDirecta = '')
        SET @DocAdjDirecta = NULL;

    DECLARE @IdPeticionOferta INT;

    SET NOCOUNT ON;
    INSERT INTO MM_PeticionOferta
    (
        IdSolicitudPedido,
        IdSubcontratista,
        CreadoPor,
        CreadoEl,
        Activo,
        Visto,
        Iniciada,
        IdTipoProceso,
        JustificacionAdjDirecta,
        DocAdjudicacionDirecta,
		CotizacionRestringida
    )
    VALUES
    (@IdSolicitudPedido, @IdProveedor, @IdUsuario, GETDATE(), 1, 1, 0, @IdTipoProceso, @JustificacionAdjDirecta,
     @DocAdjDirecta,@CotizacionRestringida);

    SELECT @@IDENTITY AS IdPeticionOferta;


END;



