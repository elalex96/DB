CREATE PROCEDURE [dbo].[sp_EN_TablerosContratistaAplicacion]--10061
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

	CREATE TABLE #Contratos(IdContrato INT)
	CREATE TABLE #Contratistas(IdContratista INT)
	
	INSERT INTO #Contratistas (IdContratista)
	SELECT	CA.IdContratista
	FROM 
		AP_PerfilUsuario	PU
	JOIN
		AP_Perfil	P
		ON PU.PerfilID	=	P.IdPerfil
	JOIN
		CO_Contrato	C
		ON	P.IdContrato	=	C.IdContrato
	JOIN
		CO_Contratista	CA
		ON	C.IdContratista	=	CA.IdContratista
	WHERE 
		UsuarioID	=	@idUsuario
	GROUP BY CA.IdContratista

	INSERT INTO #Contratos(IdContrato)
	SELECT 
		IdContrato
	FROM 
		CO_Contrato	C
	JOIN
		#Contratistas	CA
		ON	C.IdContratista	=	CA.IdContratista

	SELECT
		IdTableroContrato,
		TC.IdContrato,
		NumeroContrato,
		Workbook,
		Sheet,
		Tabs,
		Site,
		DNS,
		TC.Activo,
		HeightPX,
		IdRol,
		NombreMostrar,
		Parametros,
		UserTableau,
		isnull(MuestraToolbar,0) as MuestraToolbar
	FROM
		EN_TableroContrato	TC
	JOIN
		#Contratos	CT
		ON	TC.IdContrato	=	CT.IdContrato
	JOIN
		CO_Contrato	C
		ON	CT.IdContrato	=	C.IdContrato
	WHERE
		TC.Activo	=	1
END
