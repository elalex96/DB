CREATE PROCEDURE [dbo].[Ta_ObtenerOfficeUserDescripcion]
@Descripcion varchar(300)
AS
BEGIN
	select 
	REPLACE(TAS.loginUri,'##TENANT##',TAS.Tenant) as LoginTokenUri,
	REPLACE(REPLACE(TAS.TokenUri,'##CLIENT_ID##',TAS.Client_Id),'##CLIENT_SECRET##',TAS.Client_Secret) as TokeUri,
	TAS.OfficeUser,
	TAS.Server,
	TAS.Client_Id,
	TAS.Tenant,
	TAS.Client_Secret
	from TA_Office_Servers TAS  (NOLOCK)
	where LTRIM(RTRIM(TAS.Descripcion)) = LTRIM(RTRIM(@Descripcion))
END