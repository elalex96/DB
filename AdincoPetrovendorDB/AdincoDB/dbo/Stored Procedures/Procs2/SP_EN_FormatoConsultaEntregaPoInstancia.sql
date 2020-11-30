CREATE PROCEDURE [dbo].[SP_EN_FormatoConsultaEntregaPoInstancia] -- 100261,3,10061
    @Idinstancia INT,
    @idContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
		DECLARE @comentarioElaborador VARCHAR(200),
			@idMax INT,
			@URLRepositorioMax VARCHAR(MAX),
			@URLRepositorioAcuseMax VARCHAR(MAX);

		SELECT TOP 1
			@idMax	=	MAX(IdLineaTiempo),
			@comentarioElaborador	=	Comentario,
			@URLRepositorioMax	=	
			CASE 
				ContieneURLRepositorio
			WHEN
				1
			THEN
			URLRepositorio
			ELSE
				''
			END
	FROM 
		EN_HistorialAprobacionesLineaTiempo
	WHERE 
		idInstanciaEntregable	=	@Idinstancia
		AND	idTipoOperacion	=	2
		AND	Activo	=	1
	GROUP BY 
		Comentario,
		IdHistorialAprobacionesVersion,
		CASE 
				ContieneURLRepositorio
			WHEN
				1
			THEN
			URLRepositorio
			ELSE
				''
			END
	ORDER BY 
		IdHistorialAprobacionesVersion	DESC;


	SELECT @URLRepositorioAcuseMax = URLRepositorio
			FROM 
		EN_HistorialAprobacionesLineaTiempo
	WHERE 
		idInstanciaEntregable	=	@Idinstancia
		AND	idTipoOperacion	=	7
		AND	Activo	=	1
		AND IdLineaTiempo=@idMax


    SELECT E.IdEntregable,
           IE.idInstanciaEntregable,
           DocumentoEntregable,
           ISNULL(MarcoLegal, '') AS MarcoLegal,
           ISNULL(TituloAnexo, '') AS TituloAnexo,
           ISNULL(Capitulo, '') AS Capitulo,
           Descripcion,
           ISNULL(Seccion, '') AS Seccion,
           ISNULL(Articulo, '') AS Articulo,
           ISNULL(R.Regulador, '') AS Regulador,
           ISNULL(f.FrecuenciaEntregable, 'Entregable Interno') AS FrecuenciaEntregable,
           E.Consecutivo,
		   IE.FechaCalculadaEntregaReg,
		   IE.FechasLimiteAprobacion,
		   IE.FechaRealEntregaRegulador,
		   @comentarioElaborador AS ComentarioElaborador,
		   @URLRepositorioMax AS UrlRepositorio,
		   @URLRepositorioAcuseMax  AS UrlRepositorioAcuse
    FROM 
		EN_InstanciasEntregable IE
    JOIN 
		EN_ContratoEntregable CE 
		ON IE.IdContratoEntregable = CE.IdContratoEntregable
    JOIN 
		EN_Entregable E 
		ON CE.IdEntregable = E.IdEntregable
    LEFT JOIN 
		EN_MarcoLegal ML 
		ON E.IdMarcoLegal = ML.IdMarcoLegal
    LEFT JOIN 
		dbo.EN_FrecuenciaEntregable f 
		ON E.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
    LEFT JOIN 
		dbo.CO_Regulador R ON E.IdRegulador = R.IdRegulador
    WHERE IE.idInstanciaEntregable = @Idinstancia;
END;


