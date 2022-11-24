-- =============================================
-- Author:		<Jose Roman>
-- Create date: <11/04/2018>
-- Description:	<Se agrega la consulta de los documentos anexo>
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================

CREATE PROCEDURE [dbo].[SP_CO_ConsultarDocumentosAnexosCotizacion]
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdCotizacion INT
AS
	BEGIN
		SELECT TDB.IdDocBases AS IdDocumento, 'Bases' AS TipoDocumento, TDB.NombreDoc AS NombreDocumento
		FROM dbo.TA_DocBasesOperacion AS TDB  (NOLOCK)
		JOIN dbo.TA_Operacion AS O  (NOLOCK)
			ON TDB.IdOperacion = O.IdOperacion  
		WHERE 
		O.IdOperacion = @IdOperacion
		AND TDB.Activo = 1

		UNION

		SELECT TDF.IdDocFianza AS IdDocumento, 'Fianza' AS TipoDocumento, TDF.NombreDoc AS NombreDocumento
		FROM TA_DocFianzaOperacion AS TDF  (NOLOCK)
		INNER JOIN	dbo.TA_Operacion AS O  (NOLOCK)
			ON TDF.IdOperacion = O.IdOperacion 
		WHERE
		TDF.IdOperacion = @IdOperacion
		AND TDF.Activo = 1

		UNION

		SELECT		
			d.IdDocumento AS IdDocumento, 
			'Anexo' AS TipoDocumento, 
			d.NombreDoc AS NombreDocumento
		FROM	MM_DocumentosSolPed AS d  (NOLOCK)
		INNER JOIN	dbo.MM_PeticionOferta AS po  (NOLOCK)
			ON d.IdSolPed = po.IdSolicitudPedido  
		WHERE po.IdPeticionOferta = @IdCotizacion
		AND d.Activo = 1
		AND ISNULL(d.CreadoPor,0) NOT IN (3324, 3606, 2811, 2810) --> CTES

	END