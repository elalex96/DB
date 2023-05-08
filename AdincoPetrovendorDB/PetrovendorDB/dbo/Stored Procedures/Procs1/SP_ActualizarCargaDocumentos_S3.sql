-- =============================================
-- Author:	DANIEL AC
-- Create date: 26/04/2018
-- Description:	ACTUALIZAR DOCUMENTO DEL PROVEEDOR,
-- SE DESACTIVA EL DOCUMENTO ANTERIOR Y SE AGREGA EL NUEVO DOCUMENTO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <08/03/2019>
-- Description:	<Se agrega el campo de iddocumento al representante legal ya que ahora puede contener mas de un representante>
-- =============================================
-- ============================================= 
-- Author:        Alexander Gomez
-- Create date:	  09-03-2022
-- Description:   Se agrega el parametro para la fecha del documento repse
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_ActualizarCargaDocumentos_S3] @IdDocumento INT, @IdUsuario INT, @IdTipoDocumento INT ,
														 @IdTipoVal INT, @IdProveedor INT, @Documento NVARCHAR (MAX) ,
														 @FechaVigenciaREPSE DATETIME = NULL,
															--- Insertar Acta constitutiva ---
														 @NoActaConstitutiva NVARCHAR (150) = NULL, @Fecha DATE = NULL ,
														 @Nombre NVARCHAR (50) = NULL ,
														 @NoNotario NVARCHAR (150) = NULL ,
														 @LugarNotarioPublico NVARCHAR (150) = NULL ,
														 @RPPC NVARCHAR (10) = NULL ,
														 @ArchivoRPPC NVARCHAR (MAX) = NULL, @ActivoRPPC BIT = NULL ,
														 @NombreNotariaPublica NVARCHAR (360) = NULL ,
														 @IdTipoDocumentoRPPC INT = NULL, @DocumentoIdRPPC INT = NULL ,
														 @IdActaConstitutiva INT = NULL ,
															--@IdPerfil            INT = 0

															--Insertar Representante legal--
														 @APaterno NVARCHAR (50) = NULL ,
														 @AMaterno NVARCHAR (50) = NULL ,
														 @NombreUs NVARCHAR (50) = NULL ,
														 @DatosDocAcreditacion NVARCHAR (100) = NULL ,
														 @NoEscrituraPublica NVARCHAR = NULL ,
														 @FechaRepLegal DATE = NULL ,
														 @NombreNotarioRL NVARCHAR (50) = NULL ,
														 @NoNotarioRL NVARCHAR = NULL ,
														 @DireccionNotarioPublicoRL NVARCHAR (150) = NULL ,
														 @CURPRL NVARCHAR (50) = NULL, @IdRepLegal INT = NULL ,

															/*NUEVOS PARAMETROS */
														 @NombreDocumento NVARCHAR (MAX), @Mime NVARCHAR (MAX) ,
														 @Extension NVARCHAR (MAX), @Carpeta NVARCHAR (MAX) ,
														 @IdentificadorS3 NVARCHAR (MAX) ,
														 @NombreDocumentoRPPC NVARCHAR (MAX) = NULL ,
														 @MimeRPPC NVARCHAR (MAX) = NULL ,
														 @ExtensionRPPC NVARCHAR (MAX) = NULL ,
														 @IdentificadorS3RPPC NVARCHAR (MAX) = NULL ,
														 @CarpetaRPPC NVARCHAR (MAX) = NULL,

														 @Bucket nvarchar(Max) = null,
														 @BucketRPPC NVARCHAR (MAX)
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON 
		DECLARE @NOMBRETIPODOCUMENTO VARCHAR(1000);
		-- ENTRA EN ESTE CASO SI SE QUIERE ACTUALIZAR EL ACTA CONSTITUTIVA --
		IF @IdTipoDocumento = 1
			BEGIN

				-- Inactiva el acta constitutiva registrado anteriormente
				UPDATE	dbo.DG_ActaConstitutiva
				   SET	IsActivo = 0, ModificadoPor = @IdUsuario, ModificadoEn = GETDATE ()
				 WHERE	IdActaConstitutiva = @IdActaConstitutiva 

				-- Inactiva el documento del acta constitutiva registrado anteriormente --
				UPDATE	dbo.S_Documento_S3
				   SET	Activo = 0, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE ()
				 WHERE	IdDocumento = @IdDocumento 

				-- Inactiva el documento del RPPC registrado anteriormente --
				UPDATE	dbo.S_Documento_S3
				   SET	Activo = 0, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE ()
				 WHERE	IdDocumento = @DocumentoIdRPPC 

				/*--------------------------------------------------------------------------/  
		  INICIO ACTA CONSTITUTIVA
	/--------------------------------------------------------------------------*/
				-- SE INSERTA LA NUEVA ACTA CONSTITUTIVA --
				INSERT INTO [dbo].[DG_ActaConstitutiva]
					( [NoActaConstitutiva], [Fecha], [Nombre], [NoNotario], [LugarNotarioPublico], [IdProveedor] ,
					  [IsEliminado] , [IsActivo], [CreadoPor], [CreadoEn], [RPPC], [NombreNotarioPublico] )
				VALUES
					( @NoActaConstitutiva, @Fecha, @Nombre, @NoNotario, @LugarNotarioPublico, @IdProveedor, 0, 1 ,
					  @IdUsuario , GETDATE (), @RPPC, @NombreNotariaPublica ) 

				-- SE INSERTA EL DOCUMENTO DE LA NUEVA ACTA CONSTITUTIVA --
				INSERT INTO S_Documento_S3
					( IdTipoDocumento, IdUsuario, IdTipoValidacionDocumento, IdProveedor, Activo, Documento, CreadoPor ,
					  CreadoEl , NombreDocumento, Mime, Identificador, Extension, Carpeta, Bucket )
				VALUES
					( @IdTipoDocumento, @IdUsuario, @IdTipoVal, @IdProveedor, 1, @Documento, @IdUsuario, GETDATE () ,
					  @NombreDocumento , @Mime, @IdentificadorS3, @Extension, @Carpeta, @Bucket ) 

				-- SE INSERTA EL RPPC DE LA NUEVA ACTA CONSTITUTIVA --
				INSERT INTO S_Documento_S3
					( IdTipoDocumento, IdUsuario, IdTipoValidacionDocumento, IdProveedor, Activo, Documento, CreadoPor ,
					  CreadoEl , NombreDocumento, Mime, Identificador, Extension, Carpeta, Bucket )
				VALUES
					( @IdTipoDocumentoRPPC, @IdUsuario, @IdTipoVal, @IdProveedor, 1, @Documento, @IdUsuario ,
					  GETDATE (), @NombreDocumentoRPPC, @MimeRPPC, @IdentificadorS3RPPC, @ExtensionRPPC, @CarpetaRPPC, @BucketRPPC ) 

				IF @@ERROR <> 0 SELECT 'false' AS  msj 
				ELSE SELECT 'true' AS msj 
			END 

		/*--------------------------------------------------------------------------/  
		  FIN ACTA CONSTITUTIVA
	/--------------------------------------------------------------------------*/

		/*--------------------------------------------------------------------------/ 
		 INICIO REPRESENTANTE LEGAL
	/--------------------------------------------------------------------------*/

		-- ENTRA EN ESTE CASO SI SE QUIERE ACTUALIZAR EL REPRESENTANTE LEGAL --
		ELSE IF @IdTipoDocumento = 13
				 BEGIN
					 -- Inactiva al representante legal registrado anteriormente --
					 UPDATE dbo.DG_RepresentanteLegal
						SET IsActivo = 0, ModificadoPor = @IdUsuario, ModificadoEn = GETDATE ()
					  WHERE IdRepresentanteLegal = @IdRepLegal 

					 -- Inactiva el documento del representante legal registrado anteriormente --
					 UPDATE dbo.S_Documento_S3
						SET Activo = 0, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE ()
					  WHERE IdDocumento = @IdDocumento 

					 -- SE INSERTA EL DOCUMENTO DEL REPRESENTANTE LEGAL --
					 INSERT INTO	S_Documento_S3
						 ( IdTipoDocumento, IdUsuario, IdTipoValidacionDocumento, IdProveedor, Activo, Documento ,
						   CreadoPor , CreadoEl, NombreDocumento, Mime, Identificador, Extension, Carpeta, Bucket )
					 VALUES
						 ( @IdTipoDocumento, @IdUsuario, @IdTipoVal, @IdProveedor, 1, @Documento, @IdUsuario ,
						   GETDATE (), @NombreDocumento, @Mime, @IdentificadorS3, @Extension, @Carpeta, @Bucket ) 

					 SELECT @IdDocumento = @@IDENTITY

					 -- SE INSERTA AL REPRESENTANTE LEGAL --
					 INSERT INTO	DG_RepresentanteLegal
						 ( APaterno, AMaterno, Nombre, DatosDocumentoAcreditacion, NoEscrituraPublica, Fecha ,
						   NombreNotario , NoNotario, DireccionNotarioPublico, IdProveedor, IsEliminado, IsActivo ,
						   CreadoPor , CreadoEn, CURP, IdDocumento )
					 VALUES
						 ( @APaterno, @AMaterno, @NombreUs, @DatosDocAcreditacion, @NoEscrituraPublica, @FechaRepLegal ,
						   @NombreNotarioRL , @NoNotarioRL, @DireccionNotarioPublicoRL, @IdProveedor, 0, 1, @IdUsuario ,
						   GETDATE (), @CURPRL, @IdDocumento ) 

					 IF @@ERROR <> 0 SELECT 'false' AS msj 
					 ELSE SELECT 'true'	   AS msj 
				 END 

		/*--------------------------------------------------------------------------/ 
		 FIN REPRESENTANTE LEGAL
	/--------------------------------------------------------------------------*/

		/*--------------------------------------------------------------------------/ 
		INICIO DOCUMENTO NORMAL DE CUALQUIER OTRO TIPO
	/--------------------------------------------------------------------------*/
		ELSE
		BEGIN
					--ACTUALIZACION DE LA FECHA VIGENCIA REPSE
					SET @NOMBRETIPODOCUMENTO = (SELECT TOP 1 NombreTipoDocumento FROM S_TipoDocumento WHERE IdTipoDocumento = @IdTipoDocumento);
					--SE VALIDA SI EL DOCUMENTO ES DE REPSE
					IF (@NOMBRETIPODOCUMENTO = 'Certificado de aprobación de REPSE')
					BEGIN
						--SE ACTUALIZA LA FECHA DE VIGENCIA DEL REPSE
						UPDATE S_Proveedor
						SET FechaVigenciaREPSE = @FechaVigenciaREPSE
						WHERE IdProveedor = @IdProveedor;

					END
					 -- ENTRA EN ESTE CASO AL ACTUALIZAR UN DOCUMENTO DE CUALQUIER OTRO TIPO QUE NO SEA ACTA NI REPRESENTANTE LEGAL --

					 -- Inactiva el documento cuando es de cualquier otro tipo --
					 UPDATE dbo.S_Documento_S3
						SET Activo = 0, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE ()
					  WHERE IdDocumento = @IdDocumento 

					 INSERT INTO	S_Documento_S3
						 ( [IdTipoDocumento], [IdUsuario], [IdTipoValidacionDocumento], [IdProveedor], [Activo] ,
						   [Documento] , [CreadoPor], [CreadoEl], NombreDocumento, Mime, Identificador, Extension ,
						   Carpeta, Bucket )
					 VALUES
						 ( @IdTipoDocumento, @IdUsuario, @IdTipoVal, @IdProveedor, 1, @Documento, @IdUsuario ,
						   GETDATE (), @NombreDocumento, @Mime, @IdentificadorS3, @Extension, @Carpeta, @Bucket ) ;

					 IF @@ERROR <> 0 SELECT 'false' AS msj 
					 ELSE SELECT 'true'	   AS msj 
		END 

	/*--------------------------------------------------------------------------/  
		 FIN DOCUMENTO NORMAL
	/--------------------------------------------------------------------------*/
END