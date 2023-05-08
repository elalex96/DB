
CREATE PROCEDURE [dbo].[Ta_ObtenerOfficeUserDescripcion]
@Descripcion varchar(300)
AS
BEGIN
	select 
	REPLACE(TAS.loginUri,'##TENANT##',TAS.Tenant) as LoginTokenUri,
	REPLACE(REPLACE(TAS.TokenUri,'##CLIENT_ID##',TAS.Client_Id),'##CLIENT_SECRET##',TAS.Client_Secret) as TokeUri,
	TAS.OfficeUser,
	TAS.Server,
	Client_Id,
	Tenant,
	Client_Secret,
	IdContrato = min(c.IdContrato),
	TAS.IdContratista
	from TA_Office_Servers TAS  (NOLOCK)
	inner join CO_Contrato c (NOLOCK) 
	on TAS.IdCOntratista = c.IdContratista
	where TAS.idcontratista = 10014
	AND LTRIM(RTRIM(Descripcion)) = LTRIM(RTRIM(@Descripcion))
	GROUP BY 
	REPLACE(TAS.loginUri,'##TENANT##',TAS.Tenant),
	REPLACE(REPLACE(TAS.TokenUri,'##CLIENT_ID##',TAS.Client_Id),'##CLIENT_SECRET##',TAS.Client_Secret),
	TAS.OfficeUser,
	TAS.Server,
	TAS.Client_Id,
	TAS.Tenant,
	TAS.Client_Secret,
	TAS.IdContratista
END