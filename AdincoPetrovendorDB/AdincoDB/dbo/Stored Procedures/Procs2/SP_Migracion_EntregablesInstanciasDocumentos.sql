USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_Migracion_EntregablesInstanciasDocumentos'
)
    DROP PROCEDURE SP_Migracion_EntregablesInstanciasDocumentos;
GO 
/****** Object:  StoredProcedure [dbo].[TA_SP_ConsultaCorreos]    Script Date: 16/02/2022 10:47:50 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_Migracion_EntregablesInstanciasDocumentos] 
@ContratoId DATETIME,
@ProgramacionId  INT
AS
BEGIN

   -- EXEC SP_Migracion_EntregablesInstanciasDocumentos 3,316209
   -- EXEC SP_Migracion_EntregablesInstanciasDocumentos 3,316682
   	SELECT  		
		ED.NombreArchivo,
		T.NombreArchivo as TipoArchivo,
		DV.CreadoPor ArchivoImportadoPor,
		DV.CreadoEl CreadoEl,
		DV.N_version,
		ED.TextoDocumentoEntregble,
		ED.Activo
	FROM
		EN_DocumentoVersion	DV
	JOIN 
		EN_EntregableDocumento	ED 
		ON	Dv.DocumentoEntregableId	=	ED.DocumentoEntregableId
	JOIN 
		EN_TipoArchivo	T 
		ON	T.idTipoArchivo	=	ED.idTipoArchivo
	JOIN 
		AP_Usuario	u 
		ON	ed.CreadoPor =	u.UsuarioID
	WHERE 
		DV.idInstanciaEntregable	=@ProgramacionId
		AND DV.Activo	=	1	

END;



