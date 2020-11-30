
CREATE PROCEDURE [dbo].[SP_PV_BusquedaIdPetrovendor]
	@RFC varchar(max),
	@IdProveedorRegistrado int output
AS
BEGIN
     declare
		@contador int,
		@idPetrovendor int,
		@idSubContratista int,
		@idTipoRegimen int,
		@idPais int,
		@idProveedor int
		 

		set @idPetrovendor = (select IdPetroVendor from [Adinco].[dbo].[PV_Subcontratista] where RFC = @RFC)
		set @idSubContratista = (Select IdSubcontratista from [Adinco].[dbo].[PV_Subcontratista] where rfc = @RFC)
		set @contador = (Select count(IdSubcontratista) from [Adinco].[dbo].[PV_Subcontratista] where rfc = @RFC)
		
		
		if(@idPetrovendor is null and @contador > 0)
		begin

			set @idTipoRegimen = (select case 
											when TipoPersonaFiscalID = 1 then 2
											when TipoPersonaFiscalID = 2 then 1
											end
								  from [Adinco].[dbo].[PV_Subcontratista]
								  where IdSubcontratista = @idSubContratista)

			set @idPais = (select id 
							from [Petrovendor].[dbo].[PV_PaisRepublica] 
							where pais like '%' + (select pais
													from [Adinco].[dbo].[PV_Subcontratista]
													where IdSubcontratista = @idSubContratista ) + '%' collate Modern_Spanish_CI_AI)

			insert into [Petrovendor].[dbo].[S_Proveedor]
				(IdNacionalidad, RFC, IdTipoRegimen, RazonSocial, RegimenCapital, FechaConstitucion, FechaOperacion, SituacionContribuyente, FechaCambioSituacion, Pais, Entidad, Municipio, Colonia, TipoVialidad, NombreVialidad, NumExterior, NumInterior, CodigoPostal,
 Alias, IsEliminado, ImagenSrc, Activo, IdPais, DiasCredito)
				select ISNULL(NacionalidadID,1), RFC, @idTipoRegimen, ISNULL(RazonSocial,''), Capital, FechaConstitucion, FechaOperacion, SituacionContribuyente, FechaCambioSituacion, Pais, Entidad, Municipio, Colonia, TipoVialidad, NombreVialidad, NumExterior, NumInterior, CodigoPostal,
 null, IsEliminado, ImagenSrc, 0, @idPais, DiasCreditoID 
				from [Adinco].[dbo].[PV_Subcontratista]
				where [Adinco].[dbo].[PV_Subcontratista].IdSubcontratista = @idSubContratista

				SET @idPetrovendor  = (select @@IDENTITY)
				update [Adinco].[dbo].[PV_Subcontratista]
				set IdPetroVendor = @idPetrovendor
				where IdSubcontratista = @idSubContratista
		end
	   SET @IdProveedorRegistrado = @idPetrovendor
	   RETURN 
END


