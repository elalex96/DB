-- =============================================
-- Author:		Reyna Olvera
-- Create date: 23/03/2018
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[PR_InsertarCromatografiaManual] 
	-- Add the parameters for the stored procedure here
  @puntoEntrega int,@idContrato int,@fechaMesDiaAnio date,@UsuarioId int,
--***************Para Cromatografia**************
 @C1 float,@C2 float,@C3 float,@nC4 float,@lC4 float,
 @nC5 float,@lC5 float,@C6_plus float,@MOL_CO2 float,
 @MOL_N2 float,@MOL_h2S float,@PrecioPetroleo float,
 @PrecioCondensado float,@PrecioGas float,@GradosAPI float,
  @AguaSedimento float,@ViscosidadSSU float,@SalLBS_1000BLS float,@Azufre float,@PresionEntrega float
	 --*****************************
	 --exec PR_InsertarCromatografiaManual 1014,3,'2018-03-01',2,66.3,35.2,11,18.25,55.2,14.5,19.8,14.8,16.9,17.5,2.5,16.4,14.6,16.9;
AS
BEGIN
	
	SET NOCOUNT ON;
	
Declare @puntoEntregaContratoId int,@idCromatografiaValor int;
 --**Se checa si ya se encuentra agregado un idCromatografia para esa fecha y para ese contrato
 Declare @idCromatografia int;
	 Select  @idCromatografia=idCromatografia 
		 from [CO_Cromatografia]
		 where Mes=Month(@fechaMesDiaAnio) and Anio = Year(@fechaMesDiaAnio)
		 and idContrato=@idContrato

 --* si ya se encuentra agregado se ocupara para insertar la cromatografia, pero 
 --PRIMERO	se comprobara que no este insertada una misma cromatografia con el mismo punto de venta, mes y contrato,
 -- de no estar agregada una, se insertara, si no, se avisara al usuario
			 if(@idCromatografia>=1)
			 Begin 


				Select @puntoEntregaContratoId= PuntoEntregaContratoID 
					 From [CO_PuntosdeEntregaContrato]
					 where PuntoEntregaID=@puntoEntrega and idContrato=@idContrato;

			   Select @idCromatografiaValor=Count(idCromatografiaValor)
					 From CO_Cromatografia C
					 JOIN CO_CromatografiaValores CV on C.idCromatografia =CV.idCromatografia
					 JOIN [CO_PuntosdeEntregaContrato] PEC on CV.idPuntoEntregacontrato=PEC.PuntoEntregaContratoID
					 where c.idContrato=@idContrato AND MES=MONTH(@fechaMesDiaAnio) AND Anio=YEAR(@fechaMesDiaAnio)
					 AND CV.idPuntoEntregacontrato=@puntoEntregaContratoId;

					 if(@idCromatografiaValor>=1)
					 Begin 
						 Print('Ya se encuentra una insertada');
					 End
					 else 
					 Begin 
						 Insert CO_CromatografiaValores(idCromatografiaValor,idCromatografia,idPuntoEntregacontrato,C1,C2,C3,nC4,lC4,nC5,lC5,C6_plus,MOL_CO2,MOL_N2,MOL_h2S,PrecioPetroleo,PrecioCondensado,PrecioGas,GradosAPI, AguaSedimento,ViscosidadSSU,SalLBS_1000BLS,Azufre,PresionEntrega,CreadoEl,CreadoPor)
						  values(((Select MAX(idCromatografiaValor) 
					from CO_CromatografiaValores)+1),@idCromatografia,@puntoEntregaContratoId,@C1,@C2,@C3,@nC4,@lC4,@nC5,@lC5,@C6_plus,@MOL_CO2,@MOL_N2,@MOL_h2S,@PrecioPetroleo,@PrecioCondensado,@PrecioGas,@GradosAPI, @AguaSedimento,@ViscosidadSSU,@SalLBS_1000BLS,@Azufre,@PresionEntrega,GetDate(),@UsuarioId);
					 end


			 End
			 Else
			 Begin
				Insert into [CO_Cromatografia](idCromatografia,idContrato,Anio,Mes,CreadoEl,CreadoPor)
					values(((Select MAX(idCromatografia) 
					from [CO_Cromatografia])+1),@idContrato,YEAR(@fechaMesDiaAnio),MONTH(@fechaMesDiaAnio),GetDate(),@UsuarioId);

		

				Select @puntoEntregaContratoId= PuntoEntregaContratoID 
					 From [CO_PuntosdeEntregaContrato]
					 where PuntoEntregaID=@puntoEntrega and idContrato=@idContrato;

					Insert CO_CromatografiaValores(idCromatografiaValor,idCromatografia,idPuntoEntregacontrato,C1,C2,C3,nC4,lC4,nC5,lC5,C6_plus,MOL_CO2,MOL_N2,MOL_h2S,PrecioPetroleo,PrecioCondensado,PrecioGas,GradosAPI, AguaSedimento,ViscosidadSSU,SalLBS_1000BLS,Azufre,PresionEntrega,CreadoEl,CreadoPor)
						  values(((Select MAX(idCromatografiaValor) 
					from CO_CromatografiaValores)+1),(Select MAX(idCromatografia) 
					from [CO_Cromatografia]),@puntoEntregaContratoId,@C1,@C2,@C3,@nC4,@lC4,@nC5,@lC5,@C6_plus,@MOL_CO2,@MOL_N2,@MOL_h2S,@PrecioPetroleo,@PrecioCondensado,@PrecioGas,@GradosAPI, @AguaSedimento,@ViscosidadSSU,@SalLBS_1000BLS,@Azufre,@PresionEntrega,GetDate(),@UsuarioId);
			 End
END
