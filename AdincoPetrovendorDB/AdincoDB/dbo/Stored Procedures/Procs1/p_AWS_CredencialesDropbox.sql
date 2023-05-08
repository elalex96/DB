CREATE PROCEDURE [dbo].[p_AWS_CredencialesDropbox]
@ContratoId INT,
@UsuarioId INT 

as
begin

	SELECT 
	AccessTokenValue, 
	RootDefault
	from AWS_DropboxCredenciales
	where IdCOntrato = @ContratoId
	
end



