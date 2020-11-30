-- =============================================
-- Author:	Daniel A Cruz
-- Create date: 11-05-18
-- Description:	SP que agrega DOCUMENTO DE ADJUDICACIÓN UNICA DE UNA Peticion de Oferta 
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <05-11-2018 >
-- Description:	<Se agrega la fecha y el nombre de cuando y quien subio el documento>
-- =============================================
CREATE PROCEDURE SP_MM_AgregarDocumentoAnexoADPeticionOferta
    @IdPeticionOferta INT,
    @IdInvitacion INT,
    @Carpeta NVARCHAR(MAX),
    @Identificador NVARCHAR(MAX),
    @Extension NVARCHAR(MAX),
    @Mime NVARCHAR(MAX),
    @NombreDocumento NVARCHAR(MAX),
    @Descripcion NVARCHAR(MAX),
    @IdSolicitudPedido INT,
	@IdUsuario INT
AS
BEGIN

    IF @IdPeticionOferta = 0
        SET @IdPeticionOferta = NULL;

    IF @IdInvitacion = 0
        SET @IdInvitacion = NULL;


    INSERT INTO dbo.MM_PeticionOfertaADAdjunto
    (
        IdInvitacion,
        IdPeticionOferta,
        Descripcion,
        Carpeta,
        Identificador,
        Mime,
        Extension,
        NombreDocumento,
        Activo,
        IdSolicitudPedido,
		CreadoPor,
		CreadoEl
    )
    VALUES
    (   @IdInvitacion,     -- IdInvitacion - int
        @IdPeticionOferta, -- IdPeticioOferta - int
        @Descripcion,      -- Descripcion - nvarchar(max)
        @Carpeta,          -- Carpeta - nvarchar(max)
        @Identificador,    -- Identificador - nvarchar(max)
        @Mime,             -- Mime - nvarchar(max)
        @Extension,        -- Extension - nvarchar(max)
        @NombreDocumento,  -- NombreDocumento - nvarchar(max)
        1,                 -- Activo - bit   
        @IdSolicitudPedido, --IdSolicitudPedido 
		@IdUsuario,
		GETDATE()  
        );

END;

