
create FUNCTION [dbo].[fnValidarDecimales]
(
	@valor decimal(19,9),
	@decimales_permitidas int
)
RETURNS varchar(100)
AS
     BEGIN
		declare @valor_str varchar(50),
				@valor_i_2 varchar(50)

		declare @TempDecimal TABLE (i int identity, dato varchar(50))

		set @valor_str = cast(@valor as varchar(50))

		

		insert into @TempDecimal(dato)
		select 	dato = ltrim(rtrim(splitdata))		
		from [dbo].[fnSplitString](@valor_str,'.')

		if exists(
			select 1
			from @TempDecimal
			where i=2
		)
		begin

			select @valor_i_2 = dato
			from @TempDecimal
			where i=2

		
			if(len(@valor_i_2) <= @decimales_permitidas)
			begin
				return 1
			end
			else
			begin
				
				declare @valor_i_3 varchar(50),
						@len int,
						@valor_3_2 int
				set @len = len(@valor_i_2)

				set @valor_i_3 = replace(SUBSTRING( @valor_i_2,@decimales_permitidas+1,@len),'0','')

				set @valor_3_2 = cast(@valor_i_3 as int)
				
				if(@valor_3_2 > 0)
				begin
					return 0
				end
				else
				begin
					return 1
				end


			end

		end
		else
		begin
			return 1
		end


       
	   return 0;


     END;
