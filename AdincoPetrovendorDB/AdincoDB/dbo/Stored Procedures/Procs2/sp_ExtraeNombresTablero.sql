-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20200221
-- Description:	Visualiza los nombre de los tableros del contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_ExtraeNombresTablero]--10061,10146
    @idUsuario INT,
    @idContrato INT,
	@isAdmin	INT
AS
BEGIN
    SET NOCOUNT ON;

	IF(@isAdmin	=	1)
	BEGIN
		SELECT  IdTableroContrato,TB.IdContrato, NombreMostrar, C.NumeroContrato, AC.NombreAreaContractual

		FROM 
			EN_TableroContrato	TB
		JOIN
			CO_Contrato	C
			ON	TB.IdContrato	=	C.IdContrato
		JOIN
			CO_AreaContractual	AC
			ON	C.IdAreaContractual	=	AC.IdAreaContractual
		WHERE		TB.Activo	=	1
			AND C.IdContrato	=	@idContrato
	END
	ELSE
	BEGIN
		SELECT  IdTableroContrato, NombreMostrar

		FROM EN_TableroContrato
	
		WHERE	IdContrato	=	@idContrato

			AND	Activo	=	1
	END
END