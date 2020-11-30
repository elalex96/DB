-- =============================================
-- Author:		Reyna O.
-- Create date: 15/02/2018
-- Description:	checa que tipo de unidad de medida es para poder mostrar el reporte correspondiente
-- =============================================
CREATE PROCEDURE [dbo].[CO_VerificaTipodeUnidadMedidaNominacion]
	-- Add the parameters for the stored procedure here
	@idContrato int ,
@idProductoNominacion int,
@puntoEntrega int,
@FechaMesAnio  nvarchar(Max)
--@idProductoNominacionBloque int,
--@idUsuario int =0
AS
BEGIN
	
	SET NOCOUNT ON;

	Declare @mes int,
			@anio int;

	Select @mes= Month(@FechaMesAnio);
	Select @anio= Year(@FechaMesAnio);

	 Select  Top 1 idUnidadMedida
						from CO_NominacionVolumen
							where Month(idFecha)=@mes and year(idFecha)= @anio  
							and idProductoNominacion=@idProductoNominacion
							and puntoentregaId=@puntoEntrega  
							and idContrato=@idContrato 
							
END

