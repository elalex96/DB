USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_CrearNuevaCarpeta]    Script Date: 11/11/2021 09:43:14 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/10/2021
-- Description:	Creacion de nuevas carpetas para el visor de archivos
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_CrearNuevaCarpeta]
	-- Add the parameters for the stored procedure here
	@ContratoId INT,
	@Padre INT,
	@NivelPadre INT,
	@EtapaId INT,
	@ReceptorId INT,
	@InstalacionId INT,
	@EtapaPozoId	INT,
	@MarcoLegalId INT,
	@Frecuencia  NVARCHAR(max),
	@EntregableId INT,
	@NombreCarpeta NVARCHAR(max),
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO CarpetasDocumentosEntregables 
	(
		IDPadre,
		Titulo,
		EtapaId,          
		ReceptorEntregableId,
		PozoInstalacionId,
		MarcoLegalId,   
		EtapaPozoId,
		EntregableId, 
		FrecuenciaId,  
		Frecuencia,
		CantidadArchivos,
		Detalle,
		Icono,
		Acciones,
		Nivel,
		TipoArchivo,
		FechaCarga,    
		CargadoPor,
		IdContrato,
		[Activo]
	)
	VALUES
	(
		@Padre,
		@NombreCarpeta,
		CASE WHEN @EtapaId = 0 THEN NULL ELSE @EtapaId END,
		CASE WHEN @ReceptorId = 0 THEN NULL ELSE @ReceptorId END,
		CASE WHEN @InstalacionId = 0 THEN NULL ELSE @InstalacionId END,
		CASE 
			WHEN @MarcoLegalId = 0 AND @InstalacionId = 0 AND @ReceptorId != 0 AND @EtapaPozoId = 0 THEN -1
			WHEN @InstalacionId = 0 AND @ReceptorId = 0 AND @MarcoLegalId = 0 THEN NULL
			ELSE @MarcoLegalId END,
		CASE 
			WHEN @EtapaPozoId = 0 AND @InstalacionId != 0 AND @MarcoLegalId = 0 THEN -1 
			WHEN @InstalacionId = 0 AND @ReceptorId != 0 AND @MarcoLegalId != 0 THEN NULL
		ELSE @EtapaPozoId END,
		CASE WHEN @EntregableId = 0 THEN NULL ELSE @EntregableId END,
		@Frecuencia,
		@Frecuencia,
		0,
		'Carpeta Personalizada',
		'<i class="glyph-icon icon-folder" style="color: green;" title="Carpeta Personalizada"></i>',
		'<a href="javascript:;" title="Carpeta Personalizada: ' + @NombreCarpeta +'" data-html="true" data-toggle="popover" data-placement="top" data-content="<ul class=&#34;dropdown-menu display-block&#34;><li><a href=&#34;javascript:;&#34; onclick=&#34;cargarArchivoPerzonalizado('+ CAST(@NivelPadre AS NVARCHAR)  + ',##IDPADRE##,' + CAST(@EtapaId AS NVARCHAR) + ',' + CAST(@ReceptorId AS NVARCHAR) + ',' + CAST(@InstalacionId AS NVARCHAR) +',' + CAST((CASE 
													WHEN @EtapaPozoId = 0 AND @InstalacionId != 0 AND @MarcoLegalId = 0 THEN -1 
												ELSE @EtapaPozoId END) AS NVARCHAR) + ',' + CAST((CASE 
			WHEN @MarcoLegalId = 0 AND @InstalacionId = 0 AND @ReceptorId != 0 AND @EtapaPozoId = 0 THEN -1
			ELSE @MarcoLegalId END) AS NVARCHAR) + ',''' + @Frecuencia + ''','+ CAST(@EntregableId AS NVARCHAR) +')&#34;>Cargar archivo</a></li>' + 
			'<li>
                <a href=&#34;javascript:;&#34; onclick=&#34;nuevaCarpetaPer(##IDPADRE##' + ',' + CAST(@EtapaId AS NVARCHAR) + ',' + CAST(@ReceptorId AS NVARCHAR) + ',' + CAST(@EntregableId AS NVARCHAR) + ',1)&#34;>
                Nueva Carpeta
                </a>
            </li>'+
			'<li>
                <a href=&#34;javascript:;&#34; onclick=&#34;EliminarCarpeta(##ID##,##IDPADRE##,''' + CAST(@NombreCarpeta AS NVARCHAR) + ''')&#34;>
                Eliminar Carpeta
                </a>
            </li>'+
			'</ul>">' + @NombreCarpeta +'</a>',
		@NivelPadre,
		'Carpeta',
		GETDATE(),
		@IdUsuario,
		@ContratoId,
		1
	);

	UPDATE CarpetasDocumentosEntregables
	SET Acciones = REPLACE(Acciones,'##ID##',CAST(ID AS nvarchar))
	WHERE ID = SCOPE_IDENTITY();

	SELECT SCOPE_IDENTITY();

END