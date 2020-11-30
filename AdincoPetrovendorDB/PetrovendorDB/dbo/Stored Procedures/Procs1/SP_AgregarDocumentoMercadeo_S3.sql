-- =============================================
-- Author:	Pedro Acuña
-- Create date: 03-07-2018
-- Description:	SP que agrega DOCUMENTO de Mercadeo en la solicitud de oferta
-- =============================================

CREATE PROCEDURE [dbo].[SP_AgregarDocumentoMercadeo_S3] @Carpeta NVARCHAR(MAX), @Identificador NVARCHAR(MAX) ,
												@Extension NVARCHAR(MAX), @Mime NVARCHAR(MAX) ,
												@NombreDocumento NVARCHAR(MAX), @Descripcion NVARCHAR(MAX) ,
												@IdSolicitudPedido INT, @IdUsuario INT, @IdProveedor INT
AS
	BEGIN
		DECLARE @TipoAdjudicacion INT, @IdDocumentoS3 INT

		SELECT		@TipoAdjudicacion = ISNULL ( sp.IdTipoProceso, 0 )
		FROM		dbo.MM_SolicitudPedido sp
		LEFT JOIN	MM_TipoPedido tipo
			ON tipo.IdTipoPedido = sp.IdTipoProceso
		WHERE		sp.IdSolicitudPedido = @IdSolicitudPedido

		IF ( @TipoAdjudicacion = 2 ) -- Mercadeo
			BEGIN
				INSERT INTO dbo.MM_PeticionOfertaMercadeoAdjunto
					( Documento, Carpeta, Identificador, Mime, Extension, NombreDocumento, Activo, CreadoPor, CreadoEl ,
					  ModificadoPor , ModificadoEl, IdSolicitudPedido )
				VALUES
					( N'' ,					-- Documento - nvarchar(max)
					  @Carpeta ,			-- Carpeta - nvarchar(max)
					  @Identificador ,		-- Identificador - nvarchar(max)
					  @Mime ,				-- Mime - nvarchar(max)
					  @Extension ,			-- Extension - nvarchar(max)
					  @NombreDocumento ,	-- NombreDocumento - nvarchar(max)
					  1 ,					-- Activo - bit
					  @IdUsuario ,			-- CreadoPor - int
					  GETDATE () ,			-- CreadoEl - datetime
					  NULL ,				-- ModificadoPor - int
					  NULL ,				-- ModificadoEl - datetime
					  @IdSolicitudPedido	-- IdSolicitudPedido - int
					)
			END

		IF ( @TipoAdjudicacion = 4 ) --Adj Directa
			BEGIN
				INSERT INTO dbo.MM_PeticionOfertaADAdjunto
					( IdInvitacion, IdPeticionOferta, Descripcion, Documento, Carpeta, Identificador, Mime, Extension ,
					  NombreDocumento , Activo, CreadoPor, CreadoEl, ModificadoPor, ModificadoEl, IdSolicitudPedido )
				VALUES
					( 0 ,					-- IdInvitacion - int
					  NULL ,				-- IdPeticionOferta - int
					  N'' ,					-- Descripcion - nvarchar(max)
					  N'' ,					-- Documento - nvarchar(max)
					  @Carpeta ,			-- Carpeta - nvarchar(max)
					  @Identificador ,		-- Identificador - nvarchar(max)
					  @Mime ,				-- Mime - nvarchar(max)
					  @Extension ,			-- Extension - nvarchar(max)
					  @NombreDocumento ,	-- NombreDocumento - nvarchar(max)
					  1 ,					-- Activo - bit
					  @IdUsuario ,			-- CreadoPor - int
					  GETDATE () ,			-- CreadoEl - datetime
					  NULL ,				-- ModificadoPor - int
					  NULL ,				-- ModificadoEl - datetime
					  @IdSolicitudPedido	-- IdSolicitudPedido - int
					)
			END

		IF	( @TipoAdjudicacion = 8 )
		BEGIN
		    INSERT INTO dbo.S_Documento_S3
		    (
		        IdUsuario,
		        IdProveedor,
		        Activo,
		        CreadoPor,
		        CreadoEl,
		        Descripcion,
		        Carpeta,
		        Identificador,
		        Mime,
		        Extension,
		        NombreDocumento,
		        IdDocumentoTabla
		    )
		    VALUES
		    ( 
				@IdUsuario,
				@IdProveedor,
				1,
				@IdUsuario,
				GETDATE(),
				NULL,
				@Carpeta,
				@Identificador,
				@Mime,
				@Extension,
				@NombreDocumento,
				@IdSolicitudPedido				 
		    )
		END
	END