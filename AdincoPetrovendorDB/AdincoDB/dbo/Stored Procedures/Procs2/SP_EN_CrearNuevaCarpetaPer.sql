USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_CrearNuevaCarpetaPer]    Script Date: 11/11/2021 09:41:39 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/11/2021
-- Description:	Creacion de nuevas carpetas para el visor de archivos
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_CrearNuevaCarpetaPer]
	-- Add the parameters for the stored procedure here
	@ContratoId INT,
	@Padre INT,
	@EtapaId INT,
	@ReceptorId INT,
	@EntregableId INT,
	@NombreCarpeta NVARCHAR(max),
	@IdUsuario INT,
	@Nivel INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @Nivel = @Nivel + 1;

    -- Insert statements for procedure here
	INSERT INTO CarpetasDocumentosEntregables 
	(
		IDPadre,
		Titulo,
		EtapaId,          
		ReceptorEntregableId,
		EntregableId, 
		CantidadArchivos,
		Detalle,
		Icono,
		Acciones,
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
		CASE WHEN @EntregableId = 0 THEN NULL ELSE @EntregableId END,
		0,
		'Carpeta Personalizada',
		'<i class="glyph-icon icon-folder" style="color: green;" title="Carpeta Personalizada"></i>',
		'<a href="javascript:;" title="Carpeta Personalizada: ' + @NombreCarpeta +'" data-html="true" data-toggle="popover" data-placement="top" data-content="<ul class=&#34;dropdown-menu display-block&#34;>' +
		'<li><a href=&#34;javascript:;&#34; onclick=&#34;cargarArchivoPer(##IDPADRE##,' + CAST(@EtapaId AS NVARCHAR) + ',' + CAST(@ReceptorId AS NVARCHAR) + ',' + CAST(@EntregableId AS NVARCHAR) +')&#34;>Cargar archivo</a></li>' + 
		--VALIDAR QUE SOLO SE PUEDEN CREAR CARPETAS HASTA EL NIVEL 3
		CASE WHEN @Nivel <= 2 THEN	
			'<li>
                <a href=&#34;javascript:;&#34; onclick=&#34;nuevaCarpetaPer(##IDPADRE##' + ',' + CAST(@EtapaId AS NVARCHAR) + ',' + CAST(@ReceptorId AS NVARCHAR) + ',' + CAST(@EntregableId AS NVARCHAR) + ',' + CAST(@Nivel AS NVARCHAR) + ')&#34;>
                Nueva Carpeta
                </a>
            </li>'
		ELSE ''
		END +
		'<li>
                <a href=&#34;javascript:;&#34; onclick=&#34;EliminarCarpeta(##ID##,##IDPADRE##,''' + CAST(@NombreCarpeta AS NVARCHAR) + ''')&#34;>
                Eliminar Carpeta
                </a>
            </li>'+
			'</ul>">' + @NombreCarpeta +'</a>',
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