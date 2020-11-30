-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 02/11/2017
-- Description:	Procedimiento para visualizar documentos de una cotización
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <11/04/2018>
-- Description:	<Se agrega la consulta de los documentos anexo>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/10/2019>
-- Description:	<se agrego el isnull en la restriccion de usuarios>
-- =============================================

CREATE PROCEDURE [dbo].[SP_CO_ConsultarDocumentosAnexosCotizacion]
	-- Add the parameters for the stored procedure here
	@IdOperacion INT, @IdCotizacion INT
AS
	BEGIN
		SELECT		TDB.IdDocBases AS IdDocumento, 'Bases' AS TipoDocumento, TDB.NombreDoc AS NombreDocumento
		FROM		dbo.TA_DocBasesOperacion AS TDB
		INNER JOIN	dbo.TA_Operacion AS O
			ON O.IdOperacion = TDB.IdOperacion
		WHERE
					O.IdOperacion = @IdOperacion
					AND TDB.Activo = 1
		UNION
		SELECT		TDF.IdDocFianza AS IdDocumento, 'Fianza' AS TipoDocumento, TDF.NombreDoc AS NombreDocumento
		FROM		TA_DocFianzaOperacion AS TDF
		INNER JOIN	dbo.TA_Operacion AS O
			ON O.IdOperacion = TDF.IdOperacion
		WHERE
					TDF.IdOperacion = @IdOperacion
					AND TDF.Activo = 1
		UNION
		SELECT		
			d.IdDocumento AS IdDocumento, 
			'Anexo' AS TipoDocumento, 
			d.NombreDoc AS NombreDocumento
		FROM		MM_DocumentosSolPed AS d
		INNER JOIN	dbo.MM_PeticionOferta AS po
			ON po.IdSolicitudPedido = d.IdSolPed
		WHERE po.IdPeticionOferta = @IdCotizacion
				AND d.Activo = 1
				 AND ISNULL(d.CreadoPor,0) NOT IN (3324, 3606, 2811, 2810)
	END