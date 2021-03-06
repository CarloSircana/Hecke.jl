@testset "RCF" begin
  Qx, x = PolynomialRing(FlintQQ)
  k, a = number_field(x-1)
  Z = maximal_order(k)

  function doit(u::UnitRange, p::Int = 3)
    cnt = 0
    for i in u
      I = ideal(Z, i)
      r, mr = ray_class_group_p_part(p, I)
      for s in index_p_subgroups(r, fmpz(p), (A,x) -> quo(A, x)[2])
        a = ray_class_field(mr*inv(s))
        if isconductor(a, I)
          K = number_field(a)
          cnt += 1
        end
      end
    end
    return cnt
  end

  @test doit(1:100) == 16
  @test doit(10^18:10^18+100) == 18
  @test doit(10^18:10^18+1000, 11) == 2
end

