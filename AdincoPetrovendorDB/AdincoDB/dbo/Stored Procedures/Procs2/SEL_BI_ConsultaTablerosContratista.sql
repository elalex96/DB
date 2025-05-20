USE ADINCO
GO

DROP PROC IF EXISTS SEL_BI_ConsultaTablerosContratista
GO

CREATE PROC SEL_BI_ConsultaTablerosContratista
@idUsuario INT,
@idContrato INT = null
AS
BEGIN
drop table if exists #Contratos
drop table if exists #Contratistas

CREATE TABLE #Contratos(IdContrato INT)  
CREATE TABLE #Contratistas(IdContratista INT)

INSERT INTO #Contratistas (IdContratista)  
SELECT CA.IdContratista  
FROM    
AP_PerfilUsuario PU (NOLOCK)
JOIN   AP_Perfil P  (NOLOCK) 
ON PU.PerfilID = P.IdPerfil  
JOIN   CO_Contrato C   (NOLOCK)
ON P.IdContrato = C.IdContrato  
JOIN   CO_Contratista CA (NOLOCK)
ON C.IdContratista = CA.IdContratista  
WHERE    UsuarioID = @idUsuario  
GROUP BY CA.IdContratista   


INSERT INTO #Contratos(IdContrato)  
SELECT    IdContrato  
FROM    CO_Contrato C  (NOLOCK)
JOIN   #Contratistas CA   (NOLOCK)
ON C.IdContratista = CA.IdContratista   


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
  isnull(MuestraToolbar,0) as MuestraToolbar,
  TC.EsVersionCloud
 FROM  
  EN_TableroContrato TC  (NOLOCK)
 JOIN   #Contratos CT   (NOLOCK)
 ON TC.IdContrato = CT.IdContrato  
 JOIN   CO_Contrato C   (NOLOCK)
 ON CT.IdContrato = C.IdContrato  
 WHERE   TC.Activo = 1 
 END